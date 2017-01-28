
macro MainHash_Save lcopy, entr, key16, value, bounder, depth, move, ev {
local ..dont_write_move, ..write_everything, ..write_after_move, ..done

ProfileInc MainHash_Save

	if value eq edx
	else if value eq 0
		xor   edx, edx
	else
	    display 'value argument of HashTable_Save is not edx or 0'
	    display 13,10
	    err
	end if

	if move eq eax
	else if move eq 0
		xor   eax, eax
	else
	    display 'move argument of HashTable_Save is not eax or 0'
	    display 13,10
	    err
	end if

		mov   rcx, qword[entr]
		mov   qword[lcopy], rcx


		mov   rcx, entr
		shr   ecx, 3  -  1
		and   ecx, 3 shl 1
	     Assert   b, ecx, 3 shl 1, 'index 3 in cluster encountered'
		neg   rcx
		lea   rcx, [8*3+3*rcx]
		add   rcx, entr


		cmp   key16, word[rcx]
		jne   ..write_everything

if move eq 0
	if bounder eq BOUND_EXACT
		jmp   ..write_after_move
	else
	end if


else
	       test   eax, eax
	if bounder eq BOUND_EXACT
		 jz   ..write_after_move
	else
		 jz   ..dont_write_move
	end if
		mov   word[lcopy+MainHashEntry.move], ax
end if

..dont_write_move:

	if bounder eq BOUND_EXACT
		jmp   ..write_after_move
	else
		mov   al, bounder
		cmp   al, BOUND_EXACT
		 je   ..write_after_move
	      movsx   eax, byte[lcopy+MainHashEntry.depth]
		sub   eax, 4
		cmp   al, depth
		 jl   ..write_after_move
		jmp   ..done
	end if

..write_everything:
		mov   word[lcopy+MainHashEntry.move], ax
		mov   word[rcx], key16
..write_after_move:
		mov   al, [mainHash.date]
		 or   al, bounder
		mov   byte[lcopy+MainHashEntry.genBound], al
		mov   al, depth
		mov   byte[lcopy+MainHashEntry.depth], al
    if ev eqtype 0
		mov   word[lcopy+MainHashEntry.eval], ev
    else
	      movsx   eax, ev
		mov   word[lcopy+MainHashEntry.eval], ax
    end if
		mov   word[lcopy+MainHashEntry.value], dx
..done:
		mov   rax, qword[lcopy]
		mov   qword[entr], rax

}
