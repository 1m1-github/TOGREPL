module TOGREPL

# using REPL
using ReplMaker
using LoopOS: listen, Peripheral
import Base.take!, Base.put!

struct repl <: Peripheral
    # r::AbstractREPL
    c::Channel{String}
end
take!(::repl) = take!(REPLINSTANCE.c)
put!(::repl, a) = println(stdout, a)
state(::repl) = "TOGREPL.REPL"
const REPLINSTANCE = repl(Channel{String}(Inf))

# old code
# struct REPLInput <: Peripheral
#     c::Channel{String}
# end
# take!(::REPLInput) = take!(REPL.c)
# const REPLINPUT = REPLInput(Channel{String}(Inf))
# struct REPLOutput <: Peripheral end
# put!(::REPLOutput, a) = println(stdout, a)
# old code

repl_parse(s) = put!(REPLINSTANCE.c, string(strip("""$s""")))
# repl_parse(s) = println(s)

# function awaken(GOD)
function awaken()
    # term = REPL.Terminals.TTYTerminal("tog", stdin, stdout, stderr)
    # REPLINSTANCE[] = repl(LineEditREPL(term, true, true))
    atreplinit(repl ->
        REPLINSTANCE[] = (ReplMaker.initrepl(
            repl_parse,
            repl=repl,
            prompt_text="> ",
            prompt_color=:light_cyan,
            start_key="\\C-G", # "\x07",
            mode_name="GOD",
        )))
    # write(stdin.buffer, "\x07")
    # GOD && write(stdin.buffer, "\x07")
    # listen(REPLINSTANCE[])
    # REPL.run_repl(REPLINSTANCE[].r)
end

end
