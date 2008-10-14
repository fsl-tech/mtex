function plot_gui(fig)
% interactively change plot

if nargin == 0, fig = gcf;end

%% check whether gui allready exists

gui = findobj('name','Modify Plot');
if ~isempty(gui), figure(gui(1));return;end

w = 400;
h = 230;
dw = 10;

%% define gui
scrsz = get(0,'ScreenSize');
gui = figure('MenuBar','none',...
 'Name','Modify Plot',...
 'Resize','off',...
 'NumberTitle','off',...
 'Color',get(0,'defaultUicontrolBackgroundColor'),...
 'Position',[(scrsz(3)-w)/2 (scrsz(4)-h)/2 w h]);
%  % 'WindowStyle','modal',...

an = uibuttongroup('title','Annotations',...
  'Parent',gui,...
  'units','pixels','position',[dw 50 (w-3*dw)/2 150]);

o = findall(fig,'type','axes','tag','S2Grid');
v = (~isempty(o) && strcmp(get(o(1),'box'),'on'));
uicontrol(...
  'Parent',an,...
  'Style','check',...
  'String','Box',...
  'UserData','box',...
  'Value',v,...
  'position',[10 110 100 20]);

v = (~isempty(o) && strcmp(get(o(1),'xgrid'),'on')) || ...
  ~isempty(findall(fig,'tag','grid','visible','on'));

uicontrol(...
  'Parent',an,...
  'Style','check',...
  'String','Grid',...
  'UserData','grid',...
  'Value',v,...
  'position',[10 90 100 20]);

v = (~isempty(o) && ~isempty(get(o(1),'xticklabel'))) ||...
  ~isempty(findall(fig,'tag','ticks','visible','on'));
uicontrol(...
  'Parent',an,...
  'Style','check',...
  'String','Grid Ticks',...
  'userdata','ticks',...
  'Value',v,...
  'position',[10 70 100 20]);

o = findall(fig,'tag','label');
v = ~isempty(o) && strcmp(get(o(1),'visible'),'on');
uicontrol(...
  'Parent',an,...
  'Style','check',...
  'String','Labels',...
  'Value',v,...
  'userdata','label',...
  'position',[10 50 100 20]);

v = ~all(all(get(fig,'colormap')==colormap('jet')));
uicontrol(...
  'Parent',an,...
  'Style','check',...
  'String','Gray Colormap',...
  'Value',v,...
  'userdata','gray',...
  'position',[10 30 130 20]);


o = findall(fig,'tag','minmax');
v = ~isempty(o) && strcmp(get(o(1),'visible'),'on');
uicontrol(...
  'Parent',an,...
  'Style','check',...
  'String','Min / Max',...
  'userdata','minmax',...
  'Value',v,...
  'position',[10 10 100 20]);

ma = uibuttongroup('title','Margins',...
  'Parent',gui,...
  'units','pixels','position',[(w-dw)/2+dw 50 (w-3*dw)/2 150]);

uicontrol(...
  'Parent',ma,...
  'HitTest','off',...
  'Style','text',...
  'String','Font Size',...
  'HorizontalAlignment','left',...
  'position',[10 100 100 20]);

o = findobj(fig,'type','text');
if ~isempty(o), v = get(o(1),'FontSize');else v = '';end
handles.FontSize = uicontrol(...
  'Parent',ma,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[110 102 60 25],...
  'String',v,...
  'Style','edit');

uicontrol(...
  'Parent',ma,...
  'HitTest','off',...
  'Style','text',...
  'String','Outer Margin',...
  'HorizontalAlignment','left',...
  'position',[10 70 100 20]);


handles.mao = uicontrol(...
  'Parent',ma,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[110 72 60 25],...
  'String',getappdata(fig,'border'),...
  'Style','edit');


uicontrol(...
  'Parent',ma,...
  'HitTest','off',...
  'Style','text',...
  'String','Y Margin',...
  'HorizontalAlignment','left',...
  'position',[10 40 80 20]);


handles.may = uicontrol(...
  'Parent',ma,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[110 42 60 25],...
  'String',getappdata(fig,'marginy'),...
  'Style','edit');

uicontrol(...
  'Parent',ma,...
  'HitTest','off',...
  'Style','text',...
  'String','X Margin',...
  'HorizontalAlignment','left',...
  'position',[10 10 80 20]);


handles.max = uicontrol(...
  'Parent',ma,...
  'BackgroundColor',[1 1 1],...
  'FontName','monospaced',...
  'HorizontalAlignment','right',...
  'Position',[110 12 60 25],...
  'String',getappdata(fig,'marginx'),...
  'Style','edit');


% buttons

uicontrol(...
  'Parent',gui,...
  'String','Apply',...
  'CallBack',{@apply,fig},...
  'Position',[w-2*dw-80*2 10 80 25]);

uicontrol(...
  'Parent',gui,...
  'String','Cancel',...
  'CallBack','close',...
  'Position',[w-dw-80 10 80 25]);

setappdata(gui,'handles',handles);

function apply(d1,d2,h) %#ok<INUSL>

handles = getappdata(gcbf,'handles');

%% check boxes
onoff = {'off','on'};
check = findall(gcbf,'style','check');
for i = 1:length(check)

  type = get(check(i),'userdata');
  oo = onoff{1+get(check(i),'value')};

  switch type
    case 'box'
      obj = findall(h,'type','axes','tag','S2Grid');
      set(obj,'box',oo,'visible',oo);
    case 'grid'
      obj = findall(h,'type','axes','tag','S2Grid');
      set(obj,'XGrid',oo,'YGrid',oo);
      obj = findall(h,'tag','grid');
      set(obj,'visible',oo);
      
    case 'ticks'
      obj = findall(h,'tag','ticks');
      set(obj,'visible',oo);
      obj = findall(h,'type','axes','tag','S2Grid');
      for o = 1:length(obj)
        if get(check(i),'value')
          set(obj(o),'xticklabel',getappdata(obj(o),'xticklabel'));
          set(obj(o),'yticklabel',getappdata(obj(o),'yticklabel'));
        else
          set(obj(o),'xticklabel',[]);
          set(obj(o),'yticklabel',[]);
        end
      end
    case 'gray'
      if get(check(i),'value')
        set(h,'colormap',flipud(colormap('gray'))/1.2);
      else
        set(h,'colormap',colormap('jet'));
      end
    otherwise
      obj = findall(h,'tag',type);
      set(obj,'visible',oo);
  end
  
end

%% FontSize
o = findobj(h,'type','text');
set(o,'FontSize',str2double(get(handles.FontSize,'string')));


%% margins

setappdata(h,'marginx',str2double(get(handles.max,'string')));
setappdata(h,'marginy',str2double(get(handles.may,'string')));
setappdata(h,'border',str2double(get(handles.mao,'string')));
  
rsf = get(h,'ResizeFcn');
if ~isempty(rsf), rsf(h,[]);end

figure(h);

