unit defineUnit;

interface

uses Messages;

const
  WM_FILE_LOADED = WM_USER + 110;

type

//  TNumCount = record
//    TotalCount,         //��ѡ��������33��21������
//    NumCount: integer;  //ѡ��������  7�� 5������
//  end;

  TBufArray = array of byte;
  PBufArray = ^TBufArray;
//  TMsgArray = array of string;

  TNumCntRec = record
    Number: byte;       //���� (���Բ�Ҫ)
    Rcount: integer;    //���ֳ��ֵĴ���
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
