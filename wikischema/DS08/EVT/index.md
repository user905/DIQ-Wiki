# EVT
| Detail | Value |
| ------ | ----- |
| type | string |
| key | True |
| description | Provide if WBS_ID_WP is provided.<br/> EVT selection that should be aligned with DS03.EVT and DS04.EVT: <br/> • A = LOE<br/> • B = weighted milestones<br/> • C = percent complete<br/> • D = units complete or for use in DS03 only, discrete<br/> • E = 50-50<br/> • F = 0-100<br/> • G = 100-0<br/> • H = variation of 50-50<br/> • J = apportioned <br/> • K = planning package (overrides where DS01.type = PP or SLPP)<br/> • L = assignment percent complete<br/> • M = calculated apportionment<br/> • N = steps<br/> • O = earned as spent<br/> • P = percent manual entry<br/> • NA = only for DS01.type = CA where ACWP.<br/> Discrete EVTs for metrics consists of B, C, D, E, F, G, H, L, N, O, P. |
| enum | * A<br/>* B<br/>* C<br/>* D<br/>* E<br/>* F<br/>* G<br/>* H<br/>* J<br/>* K<br/>* L<br/>* M<br/>* N<br/>* O<br/>* P<br/>* NA |
