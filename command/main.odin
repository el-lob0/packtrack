package main

import "core:fmt"
import "core:os/os2"
import "core:os"
import "core:strings"
import "core:strconv"


// commands:
// packtrack start
// packtrack stats
// packtrack search <QUERY>
// packtrack clear

// run as a background service (daemon) to stay awake

format_number :: proc(s: string) -> string {
    result: [dynamic]u8
    count := 0

    for i := len(s)-1; i >= 0; i -= 1 {
        append(&result, s[i])
        count += 1

        if count == 3 && i != 0 {
            append(&result, ' ')
            count = 0
        }
    }

    // Reverse the buffer in-place
    for i := 0; i < len(result)/2; i += 1 {
        j := len(result) - 1 - i
        result[i], result[j] = result[j], result[i]
    }

    return string(result[:])
}

display_usage_stats :: proc(dir_path: string) {
  /* 
     1. iterate over lines in data.txt
     2. store previous datapoint
     3. y = current - previous
     4. store all the y's in an array 
     5. display stuff
   */

  cmd := fmt.tprintf("cat %s/data.txt", dir_path)

  state, stdout, stderr, err := os2.process_exec({command={"sh", "-c", cmd}}, context.allocator)

  file := fmt.tprintf("%s", stdout)
  lines := strings.split(file, "\n")

  line := lines[len(lines)-2]

  tmp := strings.split(line, ",")

  if len(tmp) < 2 { return }

  rx, x := strconv.parse_u64(tmp[0])
  tx, y := strconv.parse_u64(tmp[1])

  fmt.printfln("Recieved: %s KB", format_number(fmt.tprintf("%d", rx)))
  fmt.printfln("Sent:     %s KB", format_number(fmt.tprintf("%d", tx)))
}

main :: proc() {

  device_name := "wlan0" // NOTE: maybe make this procedural ?

  command_warning := "Invalid command. \n \nUsage: \n  relapsium <COMMAND> [ARGUMENT] \n \nCommands: \n setdev <name>  (set the network device to capture on) \n stats \n clear "

  home := os.get_env("HOME")
  dir_path := fmt.tprintf("%s/.packtrack", home)

  if len(os.args) < 2 {
    fmt.eprintfln(command_warning)
    os.exit(0)
  }

  arg_string := os.args[1]


  switch arg_string {
  case "setdev": {
    if len(os.args) < 3 {
      fmt.eprintfln(command_warning)
      os.exit(0)
    }
    device_name = os.args[2]
  }
  case "stat": {
    display_usage_stats(dir_path)
  }
  case "clear": {
    cmd := fmt.tprintf("rm %s/data.txt", dir_path)
    state, stdout, stderr, err := os2.process_exec({command={"sh", "-c", cmd}}, context.allocator)
  }
  case: fmt.eprintfln(command_warning)
  }

  


}
