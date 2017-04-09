Thread_Think:
        stp  x29, x30, [sp, -16]!
Display "Thread_Think called from thread %x1\n"
        ldp  x29, x30, [sp], 16
        ret
MainThread_Think:
        stp  x29, x30, [sp, -16]!
Display "MainThread_Think called from thread %x1\n"
        ldp  x29, x30, [sp], 16
        ret

