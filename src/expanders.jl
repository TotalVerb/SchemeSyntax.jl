function expandmodule(name::Symbol, body...)
    Expr(:module, true, name, Expr(:block, body...))
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
    Expr(:toplevel, (Expr(:using, parts(name)...) for name in names)...)
end
