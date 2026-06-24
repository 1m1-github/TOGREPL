module TOGREPL

# using REPL
using ReplMaker, RemoteREPL
using LoopOS: listen, Peripheral
import Base.take!, Base.put!

struct repl <: Peripheral
    c::Channel{String}
end
const REPLINSTANCE = repl(Channel{String}(Inf))
take!(::Type{repl}) = begin
    @show "TOGREPL.take!", REPLINSTANCE.c
    output = take!(REPLINSTANCE.c)
    @show "TOGREPL.take!", output
    output
end
put!(::Type{repl}, a) = begin
    @show "TOGREPL.put!", a
    println(stdout, a)
end
state(::Type{repl}) = "TOGREPL.REPL"

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
const REMOTE_REPL_TASK = Ref{Task}()
# function awaken(GOD)
function awaken(;remotereplport)
    # term = REPL.Terminals.TTYTerminal("tog", stdin, stdout, stderr)
    # REPLINSTANCE[] = repl(LineEditREPL(term, true, true))
    atreplinit(r -> begin
        ReplMaker.initrepl(
            repl_parse,
            repl=r,
            prompt_text="> ",
            prompt_color=:light_cyan,
            start_key="\\C-G", # "\x07",
            mode_name="GOD",
        )
        # listen(REPLINSTANCE)
        REMOTE_REPL_TASK[] = @async serve_repl(remotereplport)
        # @show "serve_repl", replport
    end
    )
    # write(stdin.buffer, "\x07")
    # GOD && write(stdin.buffer, "\x07")
    # REPL.run_repl(REPLINSTANCE[].r)
end

end
