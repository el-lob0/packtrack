
package main

import "base:intrinsics"
import "core:fmt"
import "core:math"
import "core:os"
import "core:reflect"
import "core:strings"

// commands:
// packtrack start
// packtrack stats
// packtrack search <QUERY>
// packtrack clear

// run as a background service (daemon) to stay awake
// intercept package, record size, other data optionally (domain probably)

main :: proc() {
  fmt.println("hello world")
}
