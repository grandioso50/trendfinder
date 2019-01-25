// ExpertsLogPeeper imports
#import "ExpertsLogPeeper.dll"
int FindLogHandle(int ChartWindowHandle, string Keyword);
int GetLogRowCount(int LogHandle);
int GetLogData(int LogHandle, int RowNo, string Buff, int BuffSize);
#import
