/* Generated by Nim Compiler v1.3.7 */
/*   (c) 2020 Andreas Rumpf */
/* The generated code is subject to the original license. */
#define NIM_INTBITS 64

/* section: NIM_merge_HEADERS */

#include "nimbase.h"
#undef LANGUAGE_C
#undef MIPSEB
#undef MIPSEL
#undef PPC
#undef R3000
#undef R4000
#undef i386
#undef linux
#undef mips
#undef near
#undef far
#undef powerpc
#undef unix

/* section: NIM_merge_FRAME_DEFINES */
#define nimfr_(x, y)
#define nimln_(x, y)

/* section: NIM_merge_FORWARD_TYPES */
typedef struct tyTuple__JfHvHzMrhKkWAUvQKe0i1A tyTuple__JfHvHzMrhKkWAUvQKe0i1A;
typedef struct tyObject_Env_asyncfuturesdotnim_asyncfutures___diB2NTuAIWY0FO9c5IUJRGg tyObject_Env_asyncfuturesdotnim_asyncfutures___diB2NTuAIWY0FO9c5IUJRGg;
typedef struct TNimType TNimType;
typedef struct TNimNode TNimNode;
typedef struct tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA;
typedef struct RootObj RootObj;
typedef struct tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ;
typedef struct Exception Exception;
typedef struct NimStringDesc NimStringDesc;
typedef struct TGenericSeq TGenericSeq;
typedef struct tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w;

/* section: NIM_merge_TYPES */
typedef struct {
N_NIMCALL_PTR(void, ClP_0) (void* ClE_0);
void* ClE_0;
} tyProc__HzVCwACFYM9cx9aV62PdjtuA;
typedef struct {
N_NIMCALL_PTR(void, ClP_0) (tyProc__HzVCwACFYM9cx9aV62PdjtuA cbproc, void* ClE_0);
void* ClE_0;
} tyProc__VHS3NdmbwcdcZKmKV1JWhw;
struct tyTuple__JfHvHzMrhKkWAUvQKe0i1A {
void* Field0;
tyObject_Env_asyncfuturesdotnim_asyncfutures___diB2NTuAIWY0FO9c5IUJRGg* Field1;
};
typedef NU8 tyEnum_TNimKind__jIBKr1ejBgsfM33Kxw4j7A;
typedef NU8 tySet_tyEnum_TNimTypeFlag__v8QUszD1sWlSIWZz7mC4bQ;
typedef N_NIMCALL_PTR(void, tyProc__ojoeKfW4VYIm36I9cpDTQIg) (void* p, NI op);
typedef N_NIMCALL_PTR(void*, tyProc__WSm2xU5ARYv9aAR4l0z9c9auQ) (void* p);
struct TNimType {
NI size;
NI align;
tyEnum_TNimKind__jIBKr1ejBgsfM33Kxw4j7A kind;
tySet_tyEnum_TNimTypeFlag__v8QUszD1sWlSIWZz7mC4bQ flags;
TNimType* base;
TNimNode* node;
void* finalizer;
tyProc__ojoeKfW4VYIm36I9cpDTQIg marker;
tyProc__WSm2xU5ARYv9aAR4l0z9c9auQ deepcopy;
};
typedef NU8 tyEnum_TNimNodeKind__unfNsxrcATrufDZmpBq4HQ;
struct TNimNode {
tyEnum_TNimNodeKind__unfNsxrcATrufDZmpBq4HQ kind;
NI offset;
TNimType* typ;
NCSTRING name;
NI len;
TNimNode** sons;
};
typedef N_NIMCALL_PTR(void, tyProc__T4eqaYlFJYZUv9aG9b1TV0bQ) (void);
struct RootObj {
TNimType* m_type;
};
struct tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ {
tyProc__HzVCwACFYM9cx9aV62PdjtuA function;
tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ* next;
};
struct TGenericSeq {
NI len;
NI reserved;
};
struct NimStringDesc {
  TGenericSeq Sup;
NIM_CHAR data[SEQ_DECL_SIZE];
};
struct tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA {
  RootObj Sup;
tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ callbacks;
NIM_BOOL finished;
Exception* error;
NimStringDesc* errorStackTrace;
};
struct tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w {
  tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA Sup;
};

/* section: NIM_merge_PROC_HEADERS */
N_LIB_PRIVATE N_NIMCALL(void, nimGCvisit)(void* d, NI op);
static N_NIMCALL(void, TM__vnqLhdH9cCREQ2r9aXVOqbvQ_3)(void);
N_LIB_PRIVATE N_NIMCALL(void, nimRegisterThreadLocalMarker)(tyProc__T4eqaYlFJYZUv9aG9b1TV0bQ markerProc);
static N_NIMCALL(void, Marker_tyRef__gcUT3qWwCET3KjsqW7m5vQ)(void* p, NI op);
static N_NIMCALL(void, Marker_tyRef__TjokxNjmnZmr9bygVDVC9bvg)(void* p, NI op);

/* section: NIM_merge_DATA */
N_LIB_PRIVATE TNimType NTI__VHS3NdmbwcdcZKmKV1JWhw_;
extern TNimType NTI__vr5DoT1jILTGdRlYv1OYpw_;
extern TNimType NTI__HsJiUUcO9cHBdUCi0HwkSTA_;
extern TNimType NTI__ytyiCJqK439aF9cIibuRVpAg_;
N_LIB_PRIVATE TNimType NTI__NMMT5akQkfNlmjYrVF9a9bwA_;
N_LIB_PRIVATE TNimType NTI__tKSBWiaJMWD3JZxwqg7UFQ_;
N_LIB_PRIVATE TNimType NTI__HzVCwACFYM9cx9aV62PdjtuA_;
N_LIB_PRIVATE TNimType NTI__gcUT3qWwCET3KjsqW7m5vQ_;
extern TNimType NTI__VaVACK0bpYmqIQ0mKcHfQQ_;
extern TNimType NTI__vU9aO9cTqOMn6CBzhV8rX7Sw_;
extern TNimType NTI__77mFvmsOLKik79ci2hXkHEg_;
N_LIB_PRIVATE TNimType NTI__te3W2Tqi7xuJ7rlPtg9al5w_;
N_LIB_PRIVATE TNimType NTI__TjokxNjmnZmr9bygVDVC9bvg_;

/* section: NIM_merge_VARS */
N_LIB_PRIVATE tyProc__VHS3NdmbwcdcZKmKV1JWhw callSoonProc__9b9b4iUSd60RO2UqC52ifJ6A;

/* section: NIM_merge_PROCS */
static N_NIMCALL(void, TM__vnqLhdH9cCREQ2r9aXVOqbvQ_3)(void) {
	nimGCvisit((void*)callSoonProc__9b9b4iUSd60RO2UqC52ifJ6A.ClE_0, 0);
}
static N_NIMCALL(void, Marker_tyRef__gcUT3qWwCET3KjsqW7m5vQ)(void* p, NI op) {
	tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ* a;
	a = (tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ*)p;
	nimGCvisit((void*)(*a).function.ClE_0, op);
	nimGCvisit((void*)(*a).next, op);
}
static N_NIMCALL(void, Marker_tyRef__TjokxNjmnZmr9bygVDVC9bvg)(void* p, NI op) {
	tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w* a;
	a = (tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w*)p;
	nimGCvisit((void*)(*a).Sup.callbacks.function.ClE_0, op);
	nimGCvisit((void*)(*a).Sup.callbacks.next, op);
	nimGCvisit((void*)(*a).Sup.error, op);
	nimGCvisit((void*)(*a).Sup.errorStackTrace, op);
}
N_LIB_PRIVATE N_NIMCALL(void, stdlib_asyncfuturesInit000)(void) {
{

	nimRegisterThreadLocalMarker(TM__vnqLhdH9cCREQ2r9aXVOqbvQ_3);

}
}

N_LIB_PRIVATE N_NIMCALL(void, stdlib_asyncfuturesDatInit000)(void) {

/* section: NIM_merge_TYPE_INIT1 */
static TNimNode* TM__vnqLhdH9cCREQ2r9aXVOqbvQ_2_2[2];
static TNimNode* TM__vnqLhdH9cCREQ2r9aXVOqbvQ_4_4[4];
static TNimNode* TM__vnqLhdH9cCREQ2r9aXVOqbvQ_5_2[2];
static TNimNode* TM__vnqLhdH9cCREQ2r9aXVOqbvQ_6_2[2];
static TNimNode TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[15];

/* section: NIM_merge_TYPE_INIT3 */
NTI__VHS3NdmbwcdcZKmKV1JWhw_.size = sizeof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A);
NTI__VHS3NdmbwcdcZKmKV1JWhw_.align = NIM_ALIGNOF(tyTuple__JfHvHzMrhKkWAUvQKe0i1A);
NTI__VHS3NdmbwcdcZKmKV1JWhw_.kind = 18;
NTI__VHS3NdmbwcdcZKmKV1JWhw_.base = 0;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_2_2[0] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[1];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[1].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[1].offset = offsetof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A, Field0);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[1].typ = (&NTI__vr5DoT1jILTGdRlYv1OYpw_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[1].name = "Field0";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_2_2[1] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[2];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[2].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[2].offset = offsetof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A, Field1);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[2].typ = (&NTI__HsJiUUcO9cHBdUCi0HwkSTA_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[2].name = "Field1";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[0].len = 2; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[0].kind = 2; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[0].sons = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_2_2[0];
NTI__VHS3NdmbwcdcZKmKV1JWhw_.node = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[0];
NTI__NMMT5akQkfNlmjYrVF9a9bwA_.size = sizeof(tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA);
NTI__NMMT5akQkfNlmjYrVF9a9bwA_.align = NIM_ALIGNOF(tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA);
NTI__NMMT5akQkfNlmjYrVF9a9bwA_.kind = 17;
NTI__NMMT5akQkfNlmjYrVF9a9bwA_.base = (&NTI__ytyiCJqK439aF9cIibuRVpAg_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_4_4[0] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[4];
NTI__tKSBWiaJMWD3JZxwqg7UFQ_.size = sizeof(tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ);
NTI__tKSBWiaJMWD3JZxwqg7UFQ_.align = NIM_ALIGNOF(tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ);
NTI__tKSBWiaJMWD3JZxwqg7UFQ_.kind = 18;
NTI__tKSBWiaJMWD3JZxwqg7UFQ_.base = 0;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_5_2[0] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[6];
NTI__HzVCwACFYM9cx9aV62PdjtuA_.size = sizeof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A);
NTI__HzVCwACFYM9cx9aV62PdjtuA_.align = NIM_ALIGNOF(tyTuple__JfHvHzMrhKkWAUvQKe0i1A);
NTI__HzVCwACFYM9cx9aV62PdjtuA_.kind = 18;
NTI__HzVCwACFYM9cx9aV62PdjtuA_.base = 0;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_6_2[0] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[8];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[8].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[8].offset = offsetof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A, Field0);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[8].typ = (&NTI__vr5DoT1jILTGdRlYv1OYpw_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[8].name = "Field0";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_6_2[1] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[9];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[9].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[9].offset = offsetof(tyTuple__JfHvHzMrhKkWAUvQKe0i1A, Field1);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[9].typ = (&NTI__HsJiUUcO9cHBdUCi0HwkSTA_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[9].name = "Field1";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[7].len = 2; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[7].kind = 2; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[7].sons = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_6_2[0];
NTI__HzVCwACFYM9cx9aV62PdjtuA_.node = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[7];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[6].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[6].offset = offsetof(tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ, function);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[6].typ = (&NTI__HzVCwACFYM9cx9aV62PdjtuA_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[6].name = "function";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_5_2[1] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[10];
NTI__gcUT3qWwCET3KjsqW7m5vQ_.size = sizeof(tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ*);
NTI__gcUT3qWwCET3KjsqW7m5vQ_.align = NIM_ALIGNOF(tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ*);
NTI__gcUT3qWwCET3KjsqW7m5vQ_.kind = 22;
NTI__gcUT3qWwCET3KjsqW7m5vQ_.base = (&NTI__tKSBWiaJMWD3JZxwqg7UFQ_);
NTI__gcUT3qWwCET3KjsqW7m5vQ_.marker = Marker_tyRef__gcUT3qWwCET3KjsqW7m5vQ;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[10].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[10].offset = offsetof(tyObject_CallbackList__tKSBWiaJMWD3JZxwqg7UFQ, next);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[10].typ = (&NTI__gcUT3qWwCET3KjsqW7m5vQ_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[10].name = "next";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[5].len = 2; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[5].kind = 2; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[5].sons = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_5_2[0];
NTI__tKSBWiaJMWD3JZxwqg7UFQ_.node = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[5];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[4].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[4].offset = offsetof(tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA, callbacks);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[4].typ = (&NTI__tKSBWiaJMWD3JZxwqg7UFQ_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[4].name = "callbacks";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_4_4[1] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[11];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[11].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[11].offset = offsetof(tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA, finished);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[11].typ = (&NTI__VaVACK0bpYmqIQ0mKcHfQQ_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[11].name = "finished";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_4_4[2] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[12];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[12].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[12].offset = offsetof(tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA, error);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[12].typ = (&NTI__vU9aO9cTqOMn6CBzhV8rX7Sw_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[12].name = "error";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_4_4[3] = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[13];
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[13].kind = 1;
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[13].offset = offsetof(tyObject_FutureBasecolonObjectType___NMMT5akQkfNlmjYrVF9a9bwA, errorStackTrace);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[13].typ = (&NTI__77mFvmsOLKik79ci2hXkHEg_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[13].name = "errorStackTrace";
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[3].len = 4; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[3].kind = 2; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[3].sons = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_4_4[0];
NTI__NMMT5akQkfNlmjYrVF9a9bwA_.node = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[3];
NTI__te3W2Tqi7xuJ7rlPtg9al5w_.size = sizeof(tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w);
NTI__te3W2Tqi7xuJ7rlPtg9al5w_.align = NIM_ALIGNOF(tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w);
NTI__te3W2Tqi7xuJ7rlPtg9al5w_.kind = 17;
NTI__te3W2Tqi7xuJ7rlPtg9al5w_.base = (&NTI__NMMT5akQkfNlmjYrVF9a9bwA_);
TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[14].len = 0; TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[14].kind = 2;
NTI__te3W2Tqi7xuJ7rlPtg9al5w_.node = &TM__vnqLhdH9cCREQ2r9aXVOqbvQ_0[14];
NTI__TjokxNjmnZmr9bygVDVC9bvg_.size = sizeof(tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w*);
NTI__TjokxNjmnZmr9bygVDVC9bvg_.align = NIM_ALIGNOF(tyObject_FuturecolonObjectType___te3W2Tqi7xuJ7rlPtg9al5w*);
NTI__TjokxNjmnZmr9bygVDVC9bvg_.kind = 22;
NTI__TjokxNjmnZmr9bygVDVC9bvg_.base = (&NTI__te3W2Tqi7xuJ7rlPtg9al5w_);
NTI__TjokxNjmnZmr9bygVDVC9bvg_.marker = Marker_tyRef__TjokxNjmnZmr9bygVDVC9bvg;
}

