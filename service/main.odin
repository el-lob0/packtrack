
package main

import "core:fmt"
import "core:os/os2"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:time"


// commands:
// packtrack start
// packtrack stats
// packtrack search <QUERY>
// packtrack clear

// run as a background service (daemon) to stay awake


remove_leading_spaces :: proc (s:string) -> string {

  str := s
  for i in str {
    if i == ' ' {
      str = str[1:]
    }
    else {
      break
    }
  }
  fmt.println(str)
  return str
}



command_to_data :: proc(device: string) -> (u64, u64) {

  state, stdout, stderr, err := os2.process_exec({command={"ip", "-s", "link", "show", "dev", device}}, context.allocator)
  output := cast(string)stdout

  rpackets: u64
  tpackets: u64

  lines := strings.split(output, "\n")

  rx := false
  tx := false
  done := rx && tx
  for line in lines {
    buf: string
    bufs := strings.fields(line)
    
    if len(bufs) >=1 { buf = bufs[0] }

    if buf == "RX:" {
      rx = true
      continue
    } else if buf == "TX:" {
      tx = true
      continue
    }

    if rx {
      words := strings.fields(line)
      err : bool
      rpackets, err = strconv.parse_u64(words[0])
      rx = false
      continue
    }
    if tx {
      words := strings.fields(line)
      err : bool
      tpackets, err = strconv.parse_u64(words[0])
      tx = false
      continue
    }
  }

  return rpackets/1_000, tpackets/1_000
}

create_data_file :: proc(name: string, path: string) -> int {

  full_path := fmt.tprintf("%s/%s.txt", path, name)
  fmt.printfln(full_path)

  state, stdout, stderr, err := os2.process_exec({command={"touch", full_path}}, context.allocator)

  if stderr != nil {
    fmt.eprintln("Error creating storage file: ", err)
    return 1
  }

  return 0
}

new_datapoint :: proc(rx_kb: u64, tx_kb: u64, path: string) -> int {

  full_path := fmt.tprintf("%s/data.txt", path)

  cmd := fmt.tprintf("echo \"%d,%d\" >> %s", rx_kb, tx_kb, full_path)

  state, stdout, stderr, err := os2.process_exec({command={"sh", "-c", cmd}}, context.allocator)

  if stderr != nil {
    fmt.eprintln("Error adding data to file: ", stderr)
    return 1
  }
  return 0
}

main :: proc() {

  device_name := "wlan0" // NOTE: maybe make this procedural ?

  command_warning := "Invalid command. \n \nUsage: \n  relapsium <COMMAND> [ARGUMENT] \n \nCommands: \n setdev <name>  (set the network device to capture on) \n stats \n clear "

  home := os.get_env("HOME")


  dir_path := fmt.tprintf("%s/.packtrack", home)
  if !os.is_dir(dir_path) {
    err := os.make_directory(dir_path, 0o777)
    if err != os.ERROR_NONE {
      fmt.eprintfln("Failed to create directory:", dir_path, "error:", err)
      os.exit(1)
    }
  }

  result := create_data_file("data", dir_path)
  if result==1 { fmt.printfln("I/O error... Exiting."); os2.exit(2) }

  base_rx :u64 = 0
  base_tx :u64 = 0

  previous_time := time.tick_now()

  last := time.tick_now()
  for {

    if time.tick_since(last) >= 30*time.Second {

      last = time.tick_now()

      new_rx, new_tx := command_to_data(device_name)

      cmd := fmt.tprintf("cat %s/data.txt", dir_path)

      state, stdout, stderr, err := os2.process_exec({command={"sh", "-c", cmd}}, context.allocator)

      file := fmt.tprintf("%s", stdout)
      lines := strings.split(file, "\n")
      if len(lines) < 3 { 
        // new file, so its empty
        new_datapoint(base_rx+new_rx, base_tx+new_tx, dir_path)
        continue 
      }

      tmp := strings.split(lines[len(lines)-2], ",")
      if len(tmp) < 2 { 
        // new file, so its empty
        new_datapoint(base_rx+new_rx, base_tx+new_tx, dir_path)
        continue 
      }



      old_rx, x := strconv.parse_u64(tmp[0])
      old_tx, y := strconv.parse_u64(tmp[1])

      if old_rx > new_rx || old_tx > new_tx {
        base_rx = old_rx
        base_tx = old_tx
      }

      new_datapoint(base_rx+new_rx, base_tx+new_tx, dir_path)
    }
  }


  // NOTE: repeat this every 1000ms 
 // every iteration: if previous_time line in the file > current data point 
  // store the previous_time line as base number, then every new datapoint = base number + datapoint
 
}
