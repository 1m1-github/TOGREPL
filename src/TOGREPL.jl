module TOGREPL

using REPL, ReplMaker
using LoopOS: listen, Peripheral
import Base.take!, Base.put!

struct repl <: Peripheral r::AbstractREPL end
take!(::repl) = take!(REPL.c)
put!(::repl, a) = println(stdout, a)
state(::repl) = "TOGREPL.REPL"
const REPLINSTANCE = Ref{repl}()

# old code
# struct REPLInput <: Peripheral
#     c::Channel{String}
# end
# take!(::REPLInput) = take!(REPL.c)
# const REPLINPUT = REPLInput(Channel{String}(Inf))
# struct REPLOutput <: Peripheral end
# put!(::REPLOutput, a) = println(stdout, a)
# old code

repl_parse(s) = put!(REPL.c, string(strip("""$s""")))

# function awaken(GOD)
function awaken()
    term = REPL.Terminals.TTYTerminal("tog", stdin, stdout, stderr)
    REPLINSTANCE[] = repl(LineEditREPL(term, true, true))
    ReplMaker.initrepl(
        repl_parse,
        repl=REPLINSTANCE[].r,
        prompt_text="> ",
        prompt_color=:light_cyan,
        start_key="\\C-G", # "\x07",
        mode_name="GOD",
    )
    write(stdin.buffer, "\x07")
    # GOD && write(stdin.buffer, "\x07")
    listen(REPLINSTANCE[])
    REPL.run_repl(REPLINSTANCE[].r)
end

end
