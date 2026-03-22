# Mock Tk for testing SpreadsheetApp logic
proc toplevel {w} {
    proc $w {cmd args} { }
}
proc frame {w args} {
    proc $w {cmd args} { }
    return $w
}
proc label {w args} {
    proc $w {cmd args} { }
    return $w
}
proc entry {w args} {
    variable entryValues
    set entryValues($w) ""
    proc $w {cmd args} {
        variable entryValues
        set w [lindex [info level 0] 0]
        switch -- $cmd {
            get { return $entryValues($w) }
            insert { set entryValues($w) [lindex $args 1] }
            delete { set entryValues($w) "" }
            configure { }
        }
    }
    return $w
}
proc button {w args} {
    proc $w {cmd args} { }
    return $w
}
proc pack {args} { }
proc grid {args} { }
proc wm {args} { }
proc tk_getOpenFile {args} { return "" }
proc tk_getSaveFile {args} { return "" }
proc tk_messageBox {args} { }

# Mock json package if missing
package ifneeded json 1.0 {
    namespace eval json {
        proc json::dict {cmd args} {
            return [lindex $args 0]
        }
    }
}

# We need to simulate the variable trace as well
# But PIspread5.tk uses $entry trace which is wrong anyway.

source PIspread5.tk

# Test script
SpreadsheetApp create app .app
app addCell .app 1
app addCell .app 2

# Manually set value for Cell 1
.app.cellsFrame.f1.e insert 0 10

# Try to set a relation for Cell 2: $cell1 * 2
# PIspread5.tk setRelation is broken, so we set it manually in the internal state
# But we need to know the structure. PIspread5 uses [list $frame $entry {}]
set app::cells(2) [list .app.cellsFrame.f2 .app.cellsFrame.f2.e {$cell1 * 2}]

app updateCells

puts "Cell 1 value: [.app.cellsFrame.f1.e get]"
puts "Cell 2 value: [.app.cellsFrame.f2.e get]"

if {[.app.cellsFrame.f2.e get] == 20} {
    puts "Test Passed"
} else {
    puts "Test Failed: Expected 20, got [.app.cellsFrame.f2.e get]"
}
