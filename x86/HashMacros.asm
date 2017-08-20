
macro MainHash_Save lcopy, entr, key16, vvalue, bbounder, ddepth, mmove, eev
  local dont_write_move, write_everything, write_after_move, done

;ProfileInc MainHash_Save

  if vvalue eq edx
  else if vvalue eq 0
                xor   edx, edx
  else
    err 'val argument of HashTable_Save is not edx or 0'
  end if

  if mmove eq eax
  else if mmove eq 0
                xor   eax, eax
  else
    err 'move argument of HashTable_Save is not eax or 0'
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
		jne   write_everything

  if mmove eq 0
    if bbounder eq BOUND_EXACT
		jmp   write_after_move
    else
    end if
  else
	       test   eax, eax
    if bbounder eq BOUND_EXACT
		 jz   write_after_move
    else
		 jz   dont_write_move
    end if
		mov   word[lcopy+MainHashEntry.move], ax
  end if

dont_write_move:

  if bbounder eq BOUND_EXACT
		jmp   write_after_move
  else
		mov   al, bbounder
		cmp   al, BOUND_EXACT
		 je   write_after_move
	      movsx   eax, byte[lcopy+MainHashEntry.depth]
		sub   eax, 4
		cmp   al, ddepth
		 jl   write_after_move
		jmp   done
  end if

write_everything:
		mov   word[lcopy+MainHashEntry.move], ax
		mov   word[rcx], key16
write_after_move:
		mov   al, byte[mainHash.date]
		 or   al, bbounder
		mov   byte[lcopy+MainHashEntry.genBound], al
		mov   al, ddepth
		mov   byte[lcopy+MainHashEntry.depth], al
  match size[addr], eev
	      movsx   eax, eev
		mov   word[lcopy+MainHashEntry.eval_], ax
  else
    if eev relativeto 0
		mov   word[lcopy+MainHashEntry.eval_], eev
    else
	      movsx   eax, eev
		mov   word[lcopy+MainHashEntry.eval_], ax
    end if
  end match
		mov   word[lcopy+MainHashEntry.value_], dx
done:
		mov   rax, qword[lcopy]
		mov   qword[entr], rax
end macro
