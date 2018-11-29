/**
 * @name Use of insecure SSL/TLS version
 * @description An insecure version of SSL/TLS has been specified. This may
 *              leave the connection open to attacks.
 * @id py/insecure-protocol
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 */

import python

FunctionObject ssl_wrap_socket() {
    result = the_ssl_module().getAttribute("wrap_socket")
}

ClassObject ssl_Context_class() {
    result = the_ssl_module().getAttribute("SSLContext")
}

string insecure_version_name() {
    // For `pyOpenSSL.SSL`
    result = "SSLv2_METHOD" or
    result = "SSLv23_METHOD" or
    result = "SSLv3_METHOD" or
    result = "TLSv1_METHOD" or
    // For the `ssl` module
    result = "PROTOCOL_SSLv2" or
    result = "PROTOCOL_SSLv3" or
    result = "PROTOCOL_TLSv1"
}

private ModuleObject the_ssl_module() {
    result = any(ModuleObject m | m.getName() = "ssl")
}

private ModuleObject the_pyOpenSSL_module() {
    result = any(ModuleObject m | m.getName() = "pyOpenSSL.SSL")
}

predicate unsafe_ssl_wrap_socket_call(CallNode call, string method_name, string insecure_version) {
    (
        call = ssl_wrap_socket().getACall() and
        method_name = "deprecated method ssl.wrap_socket"
        or
        call = ssl_Context_class().getACall() and
        method_name = "ssl.SSLContext"
    )
    and
    insecure_version = insecure_version_name()
    and
    (
        call.getArgByName("ssl_version").refersTo(the_ssl_module().getAttribute(insecure_version))
        or
        // syntactic match, in case the version in question has been deprecated
        exists(ControlFlowNode arg | arg = call.getArgByName("ssl_version") |
            arg.(AttrNode).getObject(insecure_version).refersTo(the_ssl_module())
        )
    )
}

ClassObject the_pyOpenSSL_Context_class() {
    result = any(ModuleObject m | m.getName() = "pyOpenSSL.SSL").getAttribute("Context")
}

predicate unsafe_pyOpenSSL_Context_call(CallNode call, string insecure_version) {
    call = the_pyOpenSSL_Context_class().getACall() and
    insecure_version = insecure_version_name() and
    call.getArgByName("method").refersTo(the_pyOpenSSL_module().getAttribute(insecure_version))
}

from CallNode call, string method_name, string insecure_version
where
    unsafe_ssl_wrap_socket_call(call, method_name, insecure_version)
or
    unsafe_pyOpenSSL_Context_call(call, insecure_version) and method_name = "pyOpenSSL.SSL.Context"
select call, "Insecure SSL/TLS protocol version " + insecure_version + " specified in call to " + method_name + "."
