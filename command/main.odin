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


display_usage_stats :: proc() {
  /* 
     1. iterate over lines in data.txt
     2. store previous datapoint
     3. y = current - previous
     4. store all the y's in an array 
     5. display stuff
   */
}

main :: proc() {

  device_name := "wlan0" // NOTE: maybe make this procedural ?

  command_warning := "Invalid command. \n \nUsage: \n  relapsium <COMMAND> [ARGUMENT] \n \nCommands: \n setdev <name>  (set the network device to capture on) \n stats \n clear "


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
    display_usage_stats()
  }
  case "clear": {
    // rm home/.../data.txt
  }
  case: fmt.eprintfln(command_warning)
  }

  


}
