# Provide a dummy Tk package
package ifneeded Tk 8.6 {
    proc package {cmd args} {
        if {$cmd eq "require" && [lindex $args 0] eq "Tk"} {
            return 8.6
        }
    }
}
# Then mock all the widgets and functions as before.
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
proc after {delay script} {
    # Don't run periodic tasks during the test
}

# Mock json package if missing
package ifneeded json 1.0 {
    namespace eval json {
        proc json::dict {cmd args} {
            return [lindex $args 0]
        }
    }
}
# Mock fileutil package if missing
package ifneeded fileutil 1.0 {
    namespace eval fileutil {
        proc fileutil::lock {args} { }
    }
}

# Need to prevent the actual execution of the Tk event loop
rename tk::MainLoop {}
proc tk::MainLoop {} {}

# Load the file but we need to modify it to use the mocked Tk
# Instead of modifying the file, we can define the classes and then call it.
# But PIspread5.tk has the `package require Tk` at the top.
# Let's read the content of the file and strip the package requirements.
set f [open PIspread5.tk r]
set content [read $f]
close $f

# Replace "package require Tk" with nothing
regsub {package require Tk} $content {} content
regsub {package require TclOO} $content {} content
regsub {package require json} $content {} content
regsub {package require fileutil} $content {} content

eval $content

# Test script
SpreadsheetApp create app .app
app addCell .app 1
app addCell .app 2

# Manually set value for Cell 1
.app.cellsFrame.f1.e insert 0 10

# Try to set a relation for Cell 2: $cell1 * 2
# PIspread5.tk setRelation is broken, so we set it manually in the internal state
# In PIspread5, cells array is not in the global namespace but inside the object.
# Since we use OO, we can't access it directly like that unless we modify the class.
# But we can call setRelation. Oh wait, setRelation uses tk_getOpenFile which we mocked to return "".

# Let's modify PIspread5's evaluateExpression to see if it works.
# Actually, I'll just write a new test file that includes the class definition but modified.
