macro struct? name 
        macro ends?! 
                        end namespace 
                        iterate definition, args@struct 
                                match name:value, definition 
                                        store value at .name 
                                else match name==value, definition 
                                        store value at .name 
                                else match value, definition 
                                        err 'unnamed values not supported' 
                                end match 
                        end iterate 
                end struc 
                virtual at 0 
                        name name 
                        sizeof.name = $ 
                end virtual 
                purge ends? 
        end macro 
        struc name args@struct& 
                label . : sizeof.name 
                namespace . 
end macro 

macro @@ tail 
        match label, @f? 
                label tail 
                @b? equ @f? 
        end match 
        local anonymous 
        @f? equ anonymous 
end macro 

define @f? 
@@


iterate instr, push,pop 
        macro instr? op 
                local sequence 
                sequence equ op -- 
                while 1 
                        match --, sequence 
                                break 
                        else match car= cdr, sequence 
                                redefine sequence cdr 
                                match :sz, x86.car 
                                        match --, sequence 
                                                instr car 
                                                break 
                                        else match head= tail, sequence 
                                                redefine sequence tail 
                                                instr car head 
                                        end match 
                                else 
                                        instr car 
                                end match 
                        end match 
                end while 
        end macro 
end iterate


macro dalign boundary, target
    match , target
	db (boundary-1)-($+boundary-1) mod boundary dup ?
    else
	db (boundary-1)-($+boundary-1) mod boundary dup ?
    end match
end macro

macro calign value, addr
  local base,size
  match , addr
        db (value-1)-($+value-1) mod value dup 0x90
  else
    if addr>$
      base = addr-size
      size = ((base+value-1)/value*value-base)
        db size dup 90h
    else
        db ((addr+value-1)/value*value-addr) dup 90h
    end if
  end match
end macro



;macro align value,addr
;{
;  local base,size
;if addr eq
;  align value
;else
;  if addr>$
; match ='W', VERSION_OS \{
;    base = addr-size
; \}
; match ='L', VERSION_OS \{
;    base = addr-size
; \}
; match ='X', VERSION_OS \{
;    base = addr-size-$$
; \}
; match ='C', VERSION_OS \{
;    base = addr-size-$$
; \}
;    size = ((base+value-1)/value*value-base)
;    db size dup 90h
;  else
;    db ((addr+value-1)/value*value-addr) dup 90h
;  end if
;end if
;}





