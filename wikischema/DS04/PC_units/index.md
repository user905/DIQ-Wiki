# PC_units
| Detail | Value |
| ------ | ----- |
| type | number |
| description | Units % complete. <br/> If % complete = 100%, 1.00.<br/> If 99% <= % complete < 100%, 0.99 (truncate remainder).<br/>If 0 < % complete < 99%, round to 2 digits.<br/> If 0 = % complete, 0.00.<br/> Utilize if DS04.type = TD or RD and DS06.EOC = material. |
| multipleOf | 0.01 |
| minimum | 0 |
| maximum | 1 |
