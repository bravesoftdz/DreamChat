unit ULineNode;

interface
uses classes, UChatLine, VirtualTrees;

type
TLineState = (LS_LineAtRemoteUser, LS_LineObjectCreated);

//���� ����� ��������� �����-���� ������, ������� ��������� � ������ �������������
//��� ��������� [+] � �����. �.�. ��� �� ����� � ������� ���������� ���
//����������� ����. �������� � ����� ������ ���������� ������, �������
//�� ������� �� ������ Form1.ChatLines � �������� ��������� � ���� �� �����.
//����� ��� �������? �������� �� �������� �� ���� ��������� REFRESH � ������
//����� ������� �� ��� ��� ���� �� ��������. �� ����� ��� ��� ��������� �������
//� ����� ������� �� � ������ ����� ����� ������������.

type
  TLineNode = class (TPersistent)
  private
    FLineName     		     :String;
    FLineId                :cardinal;//ID ����� � ������ ����� ����� ���������
    FDisplayLineName     	 :String;
    FCreatedByCommand    	 :String;
    FLineOwner   		       :String;//��� �����, �������� ����������� �����
    FLineOwnerID   	       :cardinal;//ID �����, �������� ����������� �����
{    FNickName			       :String;
    FDisplayNickName		   :String;
    FLogin                 :String;
    FIP           		     :String;}
    FVersion		        	 :String;
    FLineUsers             :TStringList;
    FLastRefreshMessNumber :cardinal;
    FTimeCreate            :TDateTime;
    FTimeOfLastMess     	 :cardinal;
    FReceivedMessCount  	 :cardinal;
    FLastReceivedMessNumber:cardinal;//����� �� ��������� ������ ���������! (��� � ������)
    FLineType              :TLineType;
    FLineState             :TLineState;
    FIsExpanded            :boolean;
    FVirtualNode           :PVirtualNode;
  protected
  public
    property LineName        :String read FLineName write FLineName;
    property LineID          :cardinal read FLineID write FLineID;
    property DisplayLineName :String read FDisplayLineName write FDisplayLineName;
    property CreatedByCommand:String read FCreatedByCommand write FCreatedByCommand;
    property LineOwner 		   :String read FLineOwner write FLineOwner;
    property LineOwnerID 	   :cardinal read FLineOwnerID write FLineOwnerID;
{    property NickName			 :String read FNickName write FNickName;
    property DisplayNickName :String read FDisplayNickName write FDisplayNickName;//���������� � ������ �� NickName, � DisplayNickName
                                        //��� �� ������ ���� � ���� ����� ���������� ���, �� �� ���������� � ���� DisplayNickName = ComputerName_NickName
    property Login           :String read FLogin write FLogin;
    property IP           	 :String read FIP write FIP;
}
    property Version			   :String read FVersion write FVersion;
    property LineUsers       :TStringList read FLineUsers write FLineUsers;
    property TimeCreate      :TDateTime read FTimeCreate write FTimeCreate;
    property TimeOfLastMess  :cardinal read FTimeOfLastMess write FTimeOfLastMess;
    property ReceivedMessCount     :cardinal read FReceivedMessCount write FReceivedMessCount;
    property LastReceivedMessNumber:cardinal read FLastReceivedMessNumber write FLastReceivedMessNumber;//����� �� ��������� ������ ���������! (��� � ������)
    property LastRefreshMessNumber :cardinal read FLastRefreshMessNumber write FLastRefreshMessNumber;//�.�.
    property LineType 			       :TLineType read FLineType write FLineType;
    property LineState 			       :TLineState read FLineState write FLineState;
    property IsExpanded 	         :boolean read FIsExpanded write FIsExpanded;
    property VirtualNode 	         :PVirtualNode read FVirtualNode write FVirtualNode;

    procedure Assign(Source: TPersistent);override;{virtual;}
    constructor Create(Line_Name:String; Line_State:TLineState); {override;}
    destructor Destroy; override;
  published
  end;

  PLineNode = ^TLineNode;

implementation

uses SysUtils;

{-------------------------------------}
constructor TLineNode.Create(Line_Name:String; Line_State:TLineState);
begin
//TLineType = (LT_COMMON, LT_PRIVATE_CHAT, LT_COMMON_LINE);
//������� �������� ���������! LOCALUSER|REMOTEUSER
//����� ����� ��� �������� ��������� � ���� ����!
  inherited Create();
  FLineUsers   := TStringList.Create;
  FLineName    := Line_Name;
{  if (LineName = 'iTCniaM') or (LineName = '*') then
    FLineType := LT_COMMON
  else
    FLineType := Line_Type;}
  FLineState         := Line_State;
  FIsExpanded        := false;
  FVirtualNode       := nil;
end;
{-------------------------------------}
destructor TLineNode.Destroy;
begin
  FreeAndNil(FLineUsers);
  inherited Destroy;
end;
{-------------------------------------}

procedure TLineNode.Assign(Source: TPersistent);
begin
  if Source is TLineNode then
    begin
    Self.FLineName := TLineNode(Source).FLineName;
    Self.FDisplayLineName := TLineNode(Source).FDisplayLineName;
    Self.FCreatedByCommand := TLineNode(Source).FCreatedByCommand;
    Self.FLineOwner := TLineNode(Source).FLineOwner;
    //Self.FNickName := TLineNode(Source).FNickName;
    //Self.FDisplayNickName := TLineNode(Source).FDisplayNickName;
    //Self.FLogin := TLineNode(Source).FLogin;
    //Self.FIP := TLineNode(Source).FIP;
    Self.FVersion := TLineNode(Source).FVersion;
    Self.FLastRefreshMessNumber := TLineNode(Source).FLastRefreshMessNumber;
    Self.FTimeCreate := TLineNode(Source).FTimeCreate;
    Self.FTimeOfLastMess := TLineNode(Source).FTimeOfLastMess;
    Self.FReceivedMessCount := TLineNode(Source).FReceivedMessCount;
    Self.FLastReceivedMessNumber := TLineNode(Source).FLastReceivedMessNumber;
    Self.FLineUsers.Assign(TLineNode(Source).FLineUsers);
    Self.FLineType := TLineNode(Source).FLineType;
    Self.FLineState := TLineNode(Source).FLineState;
    Self.FIsExpanded := TLineNode(Source).FIsExpanded;
    Self.FVirtualNode := TLineNode(Source).FVirtualNode;
    end
  else
    inherited Assign(Source);
end;

end.
