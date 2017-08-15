
; convert 64 bit register reg to its 32 bit version
;  for >= r8, r8d is the 32 bit version

raxd equ eax
rbxd equ ebx
rcxd equ ecx
rdxd equ edx
rbpd equ ebp
rsid equ esi
rdid equ edi


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


macro PrintNewLine
                mov   al, 10
              stosb
end macro

macro NewLineData
        db 10
end macro

macro IntegerStringData number
local value, pos, digit, disp
  value = number
  if value < 0
    db '-'
    value = -value
  end if
  pos = 10000000
  disp = 0
  repeat 8
    digit = value/pos
    value = value - (digit*pos)
    pos = pos/10
    disp = disp or digit
    if disp <> 0 | pos = 1
        db '0' + digit
    end if
  end repeat
end macro


macro BuildTimeData
  local time, day, year, month, febdays
  time = %t
  day = time/(24*3600)
  day = day - (day + 365)/(3*365+366) 
  year = 1970 + day/365
  day = day mod 365 + 1
  month = 1
  if year mod 4 = 0
    febdays = 29
  else
    febdays = 28
  end if
  iterate dayscount, 31,febdays,31,30,31,30,31,31,30,31,30,31
display '0'+dayscount
display ' '
    if day > dayscount
      day = day - dayscount
      month = month + 1
    end if
  end iterate
        db '0' + (year / 1000) 
        db '0' + (year mod 1000) / 100
        db '0' + (year mod 100) / 10
        db '0' + (year mod 10)
        db '-'
        db '0' + (month / 10)
        db '0' + (month mod 10)
        db '-'
        db '0' + (day / 10)
        db '0' + (day mod 10)
end macro


;
;macro months [dayscount]
;{
;  forward
;   if DAY > dayscount
;    DAY = DAY-dayscount
;    MONTH = MONTH+1
;  forward
;   end if
;}
;
;TIME = %T
;DAY = TIME/(24*3600)
;DAY = DAY - (DAY+365)/(3*365+366)
;YEAR = 1970+DAY/365
;DAY = DAY mod 365 + 1
;MONTH = 1
;
;if YEAR mod 4 = 0
;  FEBDAYS=29
;else
;  FEBDAYS=28
;end if
;
;months 31,FEBDAYS,31,30,31,30,31,31,30,31,30,31

;macro num_to_db num, digits {
;common
;   local ..lbl, ..ptr, ..dig, ..num
;
;..lbl:
;   rb digits
;
;   ..ptr = ..lbl + digits - 1
;   ..num = num
;   repeat digits
;     ..dig = (..num mod 10) + $30
;     ..num = ..num / 10
;     store byte ..dig at ..ptr
;     ..ptr = ..ptr - 1
;   end repeat
;}
;
;
;macro create_build_time day, month, year {
;common
;  num_to_db year, 4
;  db '-'
;  num_to_db month, 2
;  db '-'
;  num_to_db day, 2
;}



; macro for string functions
;  the string m is put in the code
;  and the function fxn is called on it
macro szcall fxn, m
    local message, over
		lea   rcx, [message]
		jmp   over
   message:   db m
	      db 0
   over:       call   fxn
end macro


; should work for registers or immediates
macro ClampUnsigned x, min, max
    local Lower, Done
		cmp   x, min
		 jb   Lower
		cmp   x, max
		 jb   Done
		mov   x, max
		jmp   Done
	Lower:
		mov   x, min
	Done:
end macro


; should work for registers or immediates
macro ClampSigned x, min, max
    local Lower, Done
		cmp   x, min
		 jl   Lower
		cmp   x, max
		 jl   Done
		mov   x, max
		jmp   Done
	Lower:
		mov   x, min
	Done:
end macro



; convert from uppercase to lowercase
macro ToLower x
local Lower
		sub   x, 'A'
		cmp   x, 'Z'-'A' + 1
		jae   Lower
		add   x, ('a'-'A')
	Lower:
		add   x, 'A'
end macro

;macro print description,number
;{ 
;   display description 
;   value=number 
;   pos=100000
;   repeat 6
;      digit=value/pos 
;      value=value-(digit*pos) 
;      pos=pos/10 
;      display ('0'+digit) 
;   end repeat 
;   display $d,$a 
;}

; use this macro if you are too lazy to touch beforehand the required amount of stack
;  for functions that need more than 4K of stack space
; here we assume that the current stack pointer is in the commited range
; if size > 4096, [rsp-size] might be past the gaurd page
;  so touch the pages up to it
STACK_PAGE_SIZE = 4096
macro _chkstk_ms stackptr, size
;        print 'local size = ', size

	repeat (size+8) / STACK_PAGE_SIZE
		cmp   al, byte[stackptr - % * STACK_PAGE_SIZE]
	end repeat
end macro



; a = PopCnt(b)
macro _popcnt a, x, t
; match =1, CPU_HAS_POPCNT \{

	;if a eq x
	     popcnt   a, x
	;else
	;        xor   a, a
	;     popcnt   a, x
	;end if

; \}
; match =0, CPU_HAS_POPCNT \{
;
;	if a eq t
;	  display 'arguments of popcnt are strange'
;	  display 13,10
;	  err
;	end if
;
;	if a eq x   ; only have two registers to work with
;		mov   t, a
;		shr   t, 1
;		and   t, qword[Mask55]
;		sub   a, t
;		mov   t, a
;		shr   t, 2
;		and   a, qword[Mask33]
;		and   t, qword[Mask33]
;		add   a, t
;		mov   t, a
;		shr   t, 4
;		add   a, t
;		and   a, qword[Mask0F]
;	       imul   a, qword[Mask01]
;		shr   a, 56
;
;	else   ; can't write to x
;		mov   a, x
;		mov   t, x
;		shr   a, 1
;		and   a, qword[Mask55]
;		sub   t, a
;		mov   a, t
;		shr   t, 2
;		and   a, qword[Mask33]
;		and   t, qword[Mask33]
;		add   a, t
;		mov   t, a
;		shr   a, 4
;		add   a, t
;		and   a, qword[Mask0F]
;	       imul   a, qword[Mask01]
;		shr   a, 56
;	end if
; \}
end macro

; a = PopCnt(b) assuming PopCnt(b)<16
macro _popcnt15 a, x, t
    if CPU_HAS_POPCNT
	     popcnt   a, x
    else

	if a eq t
	  display 'arguments of popcnt15 are strange'
	  display 13,10
	  err
	end if

	if a eq x   ; only have two registers to work with
		mov   t, x
		shr   t, 1
		and   t, qword[Mask55]
		sub   x, t
		mov   t, x
		shr   t, 2
		and   x, qword[Mask33]
		and   t, qword[Mask33]
		add   x, t
	       imul   x, qword[Mask01]
		shr   x, 56

	else   ; can't write to x
		mov   a, x
		mov   t, x
		shr   a, 1
		and   a, qword[Mask55]
		sub   t, a
		mov   a, t
		shr   t, 2
		and   a, qword[Mask33]
		and   t, qword[Mask33]
		add   a, t
	       imul   a, qword[Mask11]
		shr   a, 56
	end if
    end if
end macro


; a = ClearLowestBit(b)
; carry flag is not handled consistently
macro _blsr a, b, t
    if CPU_HAS_BMI1
	       blsr  a, b
    else
	if a eq b
		lea  t, [a-1]
		and  a, t
	else
		lea  a, [b-1]
		and  a, b
	end if
    end if
end macro

; a = IsolateLowestBit(b)
; carry flag is not handled consistently
macro _blsi a, b, t
    if CPU_HAS_BMI1
	       blsi   a, b
    else
	if a eq b
		mov   t, a
		neg   a
		and   a, t
	else
		mov   a, b
		neg   a
		and   a, b
	end if
    end if
end macro


; a = And(Not(b),c)
; sign and zero flags are handled consistently
macro _andn a, b, c
;  local A, B, C
;  A equ a
;  B equ b
;  C equ c
;  if CPU_HAS_BMI1
;	       andn  A, B, C
;  else
;      if B relativeto C & B = C
;        err 'arguments of andn are strange'
;      else if A relativeto C & A = C
;		not  b
;		and  a, b
;		not  b
;      else if A relativeto B & A = B
;		not  a
;		and  a, c
;      else
;		mov  a, b
;		not  a
;		and  a, c
;      end if
;  end if


  if CPU_HAS_BMI1
	       andn  a, b, c
  else
    match size[addr], c
      if a eq b
		not  a
		and  a, c
      else
		mov  a, b
		not  a
		and  a, c
      end if
    else
      if b eq c
        err 'arguments of andn are strange'
      else if a eq c
		not  b
		and  a, b
		not  b
      else if a eq b
		not  a
		and  a, c
      else
		mov  a, b
		not  a
		and  a, c
      end if
    end match
  end if
end macro



; y = BitDeposit(x,m)  slow: only used in init
macro _pdep y,x,m,b,t,tm
local start, skip, done
; match =1, CPU_HAS_BMI2 \{
;	       pdep  y, x, m
; \}
; match =0, CPU_HAS_BMI2 \{
		mov  tm, m
		xor  y, y
		lea  b, [y+1]
	       test  tm, tm
		 jz  done
       start:   mov  t, tm
		neg  t
		and  t, tm
	       test  x, b
		 jz  skip
		 or  y, t
       skip:	lea  t, [tm-1]
		add  b, b
		and  tm, t
		jnz  start
       done:
; \}
end macro



; y = BitExtract(x,m)  slow: only used in init
macro _pext y,x,m,b,t,tm
local start, skip, done
; match =1, CPU_HAS_BMI2 \{
;	       pext  y, x, m
; \}
; match =0, CPU_HAS_BMI2 \{
		mov  tm, m
		xor  y, y
		lea  b, [y+1]
	       test  tm, tm
		 jz  done
       start:   mov  t, tm
		neg  t
		and  t, tm
	       test  t, x
		lea  t, [tm-1]
		 jz  skip
		 or  y, b
       skip:	add  b, b
		and  tm, t
		jnz  start
       done:
; \}
end macro

