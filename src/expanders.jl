function expandmodule(name::Symbol, body...)
    # TODO: use proper line information
    line = LineNumberNode(-1, "Remarkable dummy file")
    Expr(:module, true, name, Expr(:block, line, body...))
end

function expandprovide(exports::Symbol...)
    Expr(:export, exports...)
end

parts(name::Symbol) = [name]
function parts(name::Expr)
    if Meta.isexpr(name, :(.))
        [parts(name.args[1])..., name.args[2].value]
    else
        error("misformatted using")
    end
end

function expandrequire(names...)
    Expr(:toplevel, (Expr(:using, Expr(:(.), parts(name)...)) for name in names)...)
end
