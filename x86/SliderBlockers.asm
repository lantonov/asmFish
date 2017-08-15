
; version with one less branch is slightly faster
macro SliderBlockers result, sliders, s, pinners,\
		     pieces, pieces_color,\
		     b, snipers, snipersSqBB, t

local YesPinners, NoPinners, MoreThanOne

;	     Assert   e, result, 0, 'Assertion result=0 failed in slider_blockers'
;	     Assert   e, pinners, 0, 'Assertion pinners=0 failed in slider_blockers'

		mov   snipers, qword[rbp+Pos.typeBB+8*Queen]
		mov   b, snipers
		 or   snipers, qword[rbp+Pos.typeBB+8*Rook]
		and   snipers, qword[RookAttacksPDEP+8*s]
		 or   b, qword[rbp+Pos.typeBB+8*Bishop]
		and   b, qword[BishopAttacksPDEP+8*s]
		 or   snipers, b
		shl   s#d, 6+3
		lea   s, [BetweenBB+s]
		and   snipers, sliders
		 jz   NoPinners
YesPinners:
	      _blsi   snipersSqBB, snipers
		bsf   t, snipers
		mov   b, pieces
		and   b, qword[s+8*t]
		mov   t, pieces_color
		and   t, b
	      cmovz   snipersSqBB, t
		lea   t, [b-1]
	       test   t, b
		jnz   MoreThanOne
		 or   result, b
		 or   pinners, snipersSqBB
MoreThanOne:
	      _blsr   snipers, snipers, t
		jnz   YesPinners
NoPinners:
end macro



; slightly slower version with both branches
;
;macro SliderBlockers result, sliders, s, pinners,\
;                     pieces, pieces_color,\
;                     b, snipers, snipersSq, t {
;
;local ..YesPinners, ..NoPinners, ..Skip
;
;             Assert   e, result, 0, 'Assertion result=0 failed in slider_blockers'
;             Assert   e, pinners, 0, 'Assertion pinners=0 failed in slider_blockers'
;
;                mov   snipers, qword[rbp+Pos.typeBB+8*Queen]
;                mov   b, snipers
;                 or   snipers, qword[rbp+Pos.typeBB+8*Rook]
;                and   snipers, qword[RookAttacksPDEP+8*s]
;                 or   b, qword[rbp+Pos.typeBB+8*Bishop]
;                and   b, qword[BishopAttacksPDEP+8*s]
;                 or   snipers, b
;                shl   s#d, 6+3
;                lea   s, [BetweenBB+s]
;                and   snipers, sliders
;                 jz   ..NoPinners
;..YesPinners:
;                bsf   snipersSq, snipers
;                mov   b, pieces
;                and   b, qword[s+8*snipersSq]
;                lea   t, [b-1]
;               test   t, b
;                jnz   ..Skip
;                 or   result, b
;               test   b, pieces_color
;                 jz   ..Skip
;                bts   pinners, snipersSq ; pinners should not be memory here else very slow
;..Skip:
;               blsr   snipers, snipers, t
;                jnz   ..YesPinners
;..NoPinners:
;}
