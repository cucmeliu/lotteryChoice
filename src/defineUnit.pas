unit defineUnit;

interface

uses Messages;

const
  WM_FILE_LOADED = WM_USER + 110;

type

//  TNumCount = record
//    TotalCount,         //待选数字数　33、21、．．
//    NumCount: integer;  //选出数字数  7、 5、．．
//  end;

  TBufArray = array of byte;
  PBufArray = ^TBufArray;
//  TMsgArray = array of string;

  TNumCntRec = record
    Number: byte;       //数字 (可以不要)
    Rcount: integer;    //数字出现的次数
  end;
  TNumCntRecArray = array of TNumCntRec;
  PNumCntRecArray = ^TNumCntRecArray;

  TStrRec = record
    Str: string[80];
  end;

  procedure QuickSort(var r: PNumCntRecArray;
    s: integer; t: integer);

implementation

procedure QuickSort(var r: PNumCntRecArray;
    s: integer; t: integer);
begin

end;

end.

