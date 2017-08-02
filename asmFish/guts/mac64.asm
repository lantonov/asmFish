; Macroinstructions for defining data structures

macro struct name
 { virtual at 0
   fields@struct equ name
   match child parent, name \{ fields@struct equ child,fields@\#parent \}
   sub@struct equ
   struc db [val] \{ \common define field@struct .,db,<val>
			     fields@struct equ fields@struct,field@struct \}
   struc dw [val] \{ \common define field@struct .,dw,<val>
			     fields@struct equ fields@struct,field@struct \}
   struc du [val] \{ \common define field@struct .,du,<val>
			     fields@struct equ fields@struct,field@struct \}
   struc dd [val] \{ \common define field@struct .,dd,<val>
			     fields@struct equ fields@struct,field@struct \}
   struc dp [val] \{ \common define field@struct .,dp,<val>
			     fields@struct equ fields@struct,field@struct \}
   struc dq [val] \{ \common define field@struct .,dq,<val>
			     fields@struct equ fields@struct,field@struct \}
   struc dt [val] \{ \common define field@struct .,dt,<val>
			     fields@struct equ fields@struct,field@struct \}
   struc rb count \{ define field@struct .,db,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   struc rw count \{ define field@struct .,dw,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   struc rd count \{ define field@struct .,dd,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   struc rp count \{ define field@struct .,dp,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   struc rq count \{ define field@struct .,dq,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   struc rt count \{ define field@struct .,dt,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   macro db [val] \{ \common \local anonymous
		     define field@struct anonymous,db,<val>
		     fields@struct equ fields@struct,field@struct \}
   macro dw [val] \{ \common \local anonymous
		     define field@struct anonymous,dw,<val>
		     fields@struct equ fields@struct,field@struct \}
   macro du [val] \{ \common \local anonymous
		     define field@struct anonymous,du,<val>
		     fields@struct equ fields@struct,field@struct \}
   macro dd [val] \{ \common \local anonymous
		     define field@struct anonymous,dd,<val>
		     fields@struct equ fields@struct,field@struct \}
   macro dp [val] \{ \common \local anonymous
		     define field@struct anonymous,dp,<val>
		     fields@struct equ fields@struct,field@struct \}
   macro dq [val] \{ \common \local anonymous
		     define field@struct anonymous,dq,<val>
		     fields@struct equ fields@struct,field@struct \}
   macro dt [val] \{ \common \local anonymous
		     define field@struct anonymous,dt,<val>
		     fields@struct equ fields@struct,field@struct \}
   macro rb count \{ \local anonymous
		     define field@struct anonymous,db,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   macro rw count \{ \local anonymous
		     define field@struct anonymous,dw,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   macro rd count \{ \local anonymous
		     define field@struct anonymous,dd,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   macro rp count \{ \local anonymous
		     define field@struct anonymous,dp,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   macro rq count \{ \local anonymous
		     define field@struct anonymous,dq,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   macro rt count \{ \local anonymous
		     define field@struct anonymous,dt,count dup (?)
		     fields@struct equ fields@struct,field@struct \}
   macro union \{ fields@struct equ fields@struct,,union,<
		  sub@struct equ union \}
   macro struct \{ fields@struct equ fields@struct,,substruct,<
		  sub@struct equ substruct \} }

macro ends
 { match , sub@struct \{ restruc db,dw,du,dd,dp,dq,dt
			 restruc rb,rw,rd,rp,rq,rt
			 purge db,dw,du,dd,dp,dq,dt
			 purge rb,rw,rd,rp,rq,rt
			 purge union,struct
			 match name tail,fields@struct, \\{ if $
							    display 'Error: definition of ',\\`name,' contains illegal instructions.',0Dh,0Ah
							    err
							    end if \\}
			 match name=,fields,fields@struct \\{ fields@struct equ
							      make@struct name,fields
							      define fields@\\#name fields \\}
			 end virtual \}
   match any, sub@struct \{ fields@struct equ fields@struct> \}
   restore sub@struct }

macro make@struct name,[field,type,def]
 { common
    local define
    define equ name
   forward
    local sub
    match , field \{ make@substruct type,name,sub def
		     define equ define,.,sub, \}
    match any, field \{ define equ define,.#field,type,<def> \}
   common
    match fields, define \{ define@struct fields \} }

macro define@struct name,[field,type,def]
 { common
    virtual
    db `name
    load initial@struct byte from 0
    if initial@struct = '.'
    display 'Error: name of structure should not begin with a dot.',0Dh,0Ah
    err
    end if
    end virtual
    local list
    list equ
   forward
    if ~ field eq .
     name#field type def
     sizeof.#name#field = $ - name#field
    else
     label name#.#type
     rb sizeof.#type
    end if
    local value
    match any, list \{ list equ list, \}
    list equ list <value>
   common
    sizeof.#name = $
    restruc name
    match values, list \{
    struc name value \\{ \\local \\..base
    match any, fields@struct \\\{ fields@struct equ fields@struct,.,name,<values> \\\}
    match , fields@struct \\\{ label \\..base
   forward
     match , value \\\\{ field type def \\\\}
     match any, value \\\\{ field type value
			    if ~ field eq .
			     rb sizeof.#name#field - ($-field)
			    end if \\\\}
   common label . at \\..base \\\}
   \\}
    macro name value \\{
    match any, fields@struct \\\{ \\\local anonymous
				  fields@struct equ fields@struct,anonymous,name,<values> \\\}
    match , fields@struct \\\{
   forward
     match , value \\\\{ type def \\\\}
     match any, value \\\\{ \\\\local ..field
			   ..field = $
			   type value
			   if ~ field eq .
			    rb sizeof.#name#field - ($-..field)
			   end if \\\\}
   common \\\} \\} \} }

macro enable@substruct
 { macro make@substruct substruct,parent,name,[field,type,def]
    \{ \common
	\local define
	define equ parent,name
       \forward
	\local sub
	match , field \\{ match any, type \\\{ enable@substruct
					       make@substruct type,parent,sub def
					       purge make@substruct
					       define equ define,.,sub, \\\} \\}
	match any, field \\{ define equ define,.\#field,type,<def> \\}
       \common
	match fields, define \\{ define@\#substruct fields \\} \} }

enable@substruct

macro define@union parent,name,[field,type,def]
 { common
    virtual at parent#.#name
   forward
    if ~ field eq .
     virtual at parent#.#name
      parent#field type def
      sizeof.#parent#field = $ - parent#field
     end virtual
     if sizeof.#parent#field > $ - parent#.#name
      rb sizeof.#parent#field - ($ - parent#.#name)
     end if
    else
     virtual at parent#.#name
      label parent#.#type
      type def
     end virtual
     label name#.#type at parent#.#name
     if sizeof.#type > $ - parent#.#name
      rb sizeof.#type - ($ - parent#.#name)
     end if
    end if
   common
    sizeof.#name = $ - parent#.#name
    end virtual
    struc name [value] \{ \common
    label .\#name
    last@union equ
   forward
    match any, last@union \\{ virtual at .\#name
			       field type def
			      end virtual \\}
    match , last@union \\{ match , value \\\{ field type def \\\}
			   match any, value \\\{ field type value \\\} \\}
    last@union equ field
   common rb sizeof.#name - ($ - .\#name) \}
    macro name [value] \{ \common \local ..anonymous
			  ..anonymous name value \} }

macro define@substruct parent,name,[field,type,def]
 { common
    virtual at parent#.#name
   forward
    if ~ field eq .
     parent#field type def
     sizeof.#parent#field = $ - parent#field
    else
     label parent#.#type
     rb sizeof.#type
    end if
   common
    sizeof.#name = $ - parent#.#name
    end virtual
    struc name value \{
    label .\#name
   forward
     match , value \\{ field type def \\}
     match any, value \\{ field type value
			  if ~ field eq .
			   rb sizeof.#parent#field - ($-field)
			  end if \\}
   common \}
    macro name value \{ \local ..anonymous
			..anonymous name \} }


; Macroinstructions for making import section (64-bit)

macro library [name,string]
 { common
    import.data:
   forward
    local _label
    if defined name#.redundant
     if ~ name#.redundant
      dd RVA name#.lookup,0,0,RVA _label,RVA name#.address
     end if
    end if
    name#.referred = 1
   common
    dd 0,0,0,0,0
   forward
    if defined name#.redundant
     if ~ name#.redundant
      _label db string,0
	     rb RVA $ and 1
     end if
    end if }

macro import name,[label,string]
 { common
    rb (- rva $) and 7
    if defined name#.referred
     name#.lookup:
   forward
     if used label
      if string eqtype ''
       local _label
       dq RVA _label
      else
       dq 8000000000000000h + string
      end if
     end if
   common
     if $ > name#.lookup
      name#.redundant = 0
      dq 0
     else
      name#.redundant = 1
     end if
     name#.address:
   forward
     if used label
      if string eqtype ''
       label dq RVA _label
      else
       label dq 8000000000000000h + string
      end if
     end if
   common
     if ~ name#.redundant
      dq 0
     end if
   forward
     if used label & string eqtype ''
     _label dw 0
	    db string,0
	    rb RVA $ and 1
     end if
   common
    end if }

macro api [name] {}


_COMM_PAGE64_BASE_ADDRESS = 0x00007fffffe00000
_COMM_PAGE_START_ADDRESS  = 0x00007fffffe00000

_COMM_PAGE_TIME_DATA_START      = _COMM_PAGE_START_ADDRESS+0x050 ; base of offsets below (_NT_SCALE etc)
_COMM_PAGE_NT_TSC_BASE          = _COMM_PAGE_START_ADDRESS+0x050 ; used by nanotime()
_COMM_PAGE_NT_SCALE             = _COMM_PAGE_START_ADDRESS+0x058 ; used by nanotime()
_COMM_PAGE_NT_SHIFT             = _COMM_PAGE_START_ADDRESS+0x05c ; used by nanotime()
_COMM_PAGE_NT_NS_BASE           = _COMM_PAGE_START_ADDRESS+0x060 ; used by nanotime()
_COMM_PAGE_NT_GENERATION        = _COMM_PAGE_START_ADDRESS+0x068 ; used by nanotime()
_COMM_PAGE_GTOD_GENERATION      = _COMM_PAGE_START_ADDRESS+0x06c ; used by gettimeofday()
_COMM_PAGE_GTOD_NS_BASE         = _COMM_PAGE_START_ADDRESS+0x070 ; used by gettimeofday()
_COMM_PAGE_GTOD_SEC_BASE        = _COMM_PAGE_START_ADDRESS+0x078 ; used by gettimeofday()
_COMM_PAGE_END                  = _COMM_PAGE_START_ADDRESS+0xfff ; end of common page

stdin  = 0 
stdout = 1 
stderr = 2 

_NT_TSC_BASE            = 0
_NT_SCALE               = 8
_NT_SHIFT               = 12
_NT_NS_BASE             = 16
_NT_GENERATION          = 24
_GTOD_GENERATION        = 28
_GTOD_NS_BASE           = 32
_GTOD_SEC_BASE          = 40

sys_exit          =   1 + (2 shl 24)
sys_fork          =   2 + (2 shl 24)
sys_read          =   3 + (2 shl 24)
sys_write         =   4 + (2 shl 24)
sys_open          =   5 + (2 shl 24)
sys_close         =   6 + (2 shl 24)
sys_munmap        =  73 + (2 shl 24)
sys_select        =  93 + (2 shl 24)
sys_gettimeofday  = 116 + (2 shl 24)
sys_fstat         = 189 + (2 shl 24)
sys_mmap          = 197 + (2 shl 24)
sys_poll          = 230 + (2 shl 24)

VM_FLAGS_SUPERPAGE_SIZE_2MB = 1 shl 16

O_RDONLY= 00000000o 
O_WRONLY= 00000001o 
O_RDWR= 00000002o 
O_CREAT= 00000100o 

PROT_NONE       = 0x00
PROT_READ       = 0x01
PROT_WRITE      = 0x02
PROT_EXEC       = 0x04

MAP_SHARED      = 0x0001 
MAP_PRIVATE     = 0x0002
MAP_FILE        = 0x0000 
MAP_FIXED       = 0x0010
MAP_ANON        = 0x1000

