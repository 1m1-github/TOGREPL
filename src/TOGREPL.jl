module TOGREPL

# using REPL
using ReplMaker
using LoopOS: listen, Peripheral
import Base.take!, Base.put!

struct repl <: Peripheral
    # r::AbstractREPL
    c::Channel{String}
end
const REPLINSTANCE = repl(Channel{String}(Inf))
take!(::repl) = begin
    @show "TOGREPL.take!", REPLINSTANCE.c
    take!(REPLINSTANCE.c)
end
put!(::repl, a) = begin
    @show "TOGREPL.put!", a
    println(stdout, a)
end
state(::repl) = "TOGREPL.REPL"

# old code
# struct REPLInput <: Peripheral
#     c::Channel{String}
# end
# take!(::REPLInput) = take!(REPL.c)
# const REPLINPUT = REPLInput(Channel{String}(Inf))
# struct REPLOutput <: Peripheral end
# put!(::REPLOutput, a) = println(stdout, a)
# old code

repl_parse(s) = begin
    @show "TOGREPL.repl_parse", s
    put!(REPLINSTANCE.c, string(strip("""$s""")))
end
# repl_parse(s) = println(s)

# function awaken(GOD)
function awaken()
    # term = REPL.Terminals.TTYTerminal("tog", stdin, stdout, stderr)
    # REPLINSTANCE[] = repl(LineEditREPL(term, true, true))
    atreplinit(repl -> begin
        ReplMaker.initrepl(
            repl_parse,
            repl=repl,
            prompt_text="> ",
            prompt_color=:light_cyan,
            start_key="\\C-G", # "\x07",
            mode_name="GOD",
        )
        listen(REPLINSTANCE)
    end
    )
    # write(stdin.buffer, "\x07")
    # GOD && write(stdin.buffer, "\x07")
    # REPL.run_repl(REPLINSTANCE[].r)
end

end
