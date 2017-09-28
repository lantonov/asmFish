
; convert 64 bit register reg to its 32 bit version
;  for >= r8, r8d is the 32 bit version

raxd equ eax
rbxd equ ebx
rcxd equ ecx
rdxd equ edx
rbpd equ ebp
rsid equ esi
rdid equ edi


; lazy way to put an address of a string into a register
macro lstring reg, target, Mes
  local m
            lea  reg, [m]
            jmp  target
    m:
        db Mes
        db 0
end macro


macro PrintNL
  if VERSION_OS = 'W'
            mov  al, 13
          stosb
  end if
            mov  al, 10
          stosb
end macro


macro PrintNewLine
  if VERSION_OS = 'W'
                mov   al, 13
              stosb
  end if
                mov   al, 10
              stosb
end macro

macro NewLineData
  if VERSION_OS = 'W'
        db 13
  end if
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
  if CPU_HAS_POPCNT <> 0
	     popcnt   a, x
  else
    if a eq t
        err 'arguments of _popcnt15 are strange'
    end if
    match size[addr], x         ; x is memory
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
                mov   t, a
                shr   a, 4
                add   a, t
                and   a, qword[Mask0F]
               imul   a, qword[Mask01]
                shr   a, 56
    else
      if a eq x   ; only have two registers to work with
                mov   t, a
                shr   t, 1
                and   t, qword[Mask55]
                sub   a, t
                mov   t, a
                shr   t, 2
                and   a, qword[Mask33]
                and   t, qword[Mask33]
                add   a, t
                mov   t, a
                shr   t, 4
                add   a, t
                and   a, qword[Mask0F]
               imul   a, qword[Mask01]
                shr   a, 56
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
		mov   t, a
		shr   a, 4
		add   a, t
		and   a, qword[Mask0F]
	       imul   a, qword[Mask01]
		shr   a, 56
      end if
    end match
  end if
end macro

; a = PopCnt(x) assuming PopCnt(b)<16
; a and t are expected to be registers
;macro _popcnt15 a, x, t
;
;display 'touching pop15'
;
;  if CPU_HAS_POPCNT <> 0
;	     popcnt   a, x
;  else
;    if a eq t
;        err 'arguments of _popcnt15 are strange'
;    end if
;    match size[addr], x         ; x is memory
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
;	       imul   a, qword[Mask11]
;		shr   a, 56
;    else
;      if a eq x   ; only have two registers to work with
;		mov   t, x
;		shr   t, 1
;		and   t, qword[Mask55]
;		sub   x, t
;		mov   t, x
;		shr   t, 2
;		and   x, qword[Mask33]
;		and   t, qword[Mask33]
;		add   x, t
;	       imul   x, qword[Mask01]
;		shr   x, 56
;      else   ; can't write to x
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
;	       imul   a, qword[Mask11]
;		shr   a, 56
;      end if
;    end match
;  end if
;end macro


; a = ClearLowestBit(b)
; carry flag is not handled consistently
; none of a, b, t can be memory
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
; none of a, b, t can be memory
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



; y = BitDeposit(x,m)
macro _pdep y, x, m, b, t, tm
  local start, skip, done
  if CPU_HASH_BMI2 <> 0
	       pdep  y, x, m
  else
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
  end if
end macro


; y = BitExtract(x,m)
macro _pext y, x, m, b, t, tm
  local start, skip, done
  if CPU_HASH_BMI2 <> 0
	       pext  y, x, m
  else
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
  end if
end macro

