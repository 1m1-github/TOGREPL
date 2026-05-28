module TOGREPL

using REPL, ReplMaker
using LoopOS: listen, Peripheral
import Base.take!, Base.put!

struct REPLInput <: InputPeripheral
    c::Channel{String}
end
take!(::REPLInput) = take!(REPL.c)
state(::REPLInput) = "TOGREPL.REPL"
const REPLINPUT = REPLInput(Channel{String}(Inf))

struct REPLOutput <: Peripheral end
put!(::REPLOutput, a) = println(stdout, a)

repl_parse(s) = put!(REPL.c, string(strip("""$s""")))

function awaken(GOD)
    listen(REPLINPUT)
    term = REPL.Terminals.TTYTerminal("tog", stdin, stdout, stderr)
    repl = LineEditREPL(term, true, true)
    ReplMaker.initrepl(
        repl_parse,
        repl=repl,
        prompt_text="> ",
        prompt_color=:light_cyan,
        start_key="\\C-G",
        mode_name="GOD",
    )
    GOD && write(stdin.buffer, "\x07")
    REPL.run_repl(repl)
end

end
