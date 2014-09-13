/*
脚本名称：	discuz_bbs_archiver_crawler
脚本编码：	UTF-8(with BOM)
脚本说明：	discuz论坛压缩档爬虫
脚本版本：	1.0
脚本作者：	飞扬网络工作室 (fysoft)
作者官网：	http://raoyc.com/fysoft/
交流Q群：	260655062
运行环境：	作者在编码或测试此脚本时所使用的运行环境为 Windows XP SP3 + AutoHotkey(L) v1.1.10.01，其它相异于此运行环境的，请自行测试脚本兼容性问题
版权申明：	非商业使用，在此脚本基础上所作出的修改，需保留原作者署名信息（作者名和官网链接）
备注信息：	本脚本提供5d6d论坛数据免费备份一种方案，注意discuz论坛压缩档一般不含任何论坛内部附件及图片，隐藏或带权限的帖子也不会予以呈现。注意，采集爬虫需要大量时间处理网页文档数据，请耐心等待直至弹出完成窗口后退出本程序。
*/

#NoEnv
SendMode Input 
SetWorkingDir %A_ScriptDir%
;MsgBox, %A_AhkVersion%
;#Persistent
#SingleInstance ignore
;#SingleInstance off

url := "http://fable.5d6d.net/archiver/"
Gui, Add, Text, xm ym+5 w250 h20, 请输入5d6d论坛Archiver压缩档网址:
Gui, Add, Edit, xm+260 ym w300 h20 vHomeURL, %url%
Gui, Add, Button, xm+580 ym w50 h20 -default gFresh, 刷新
Gui Add, Button, xm+640 ym w120 h20 -default gCrawl, 开始爬行并采集
Gui Add, ActiveX, xm ym+30 w1000 h670 vwb, Shell.Explorer
Gui, Show, w990 h680, Discuz BBS Archiver Crawler
Gui,+Border
wb.Silent := true
wb.Navigate("http://fable.5d6d.net/archiver/")

while, wb.ReadyState != 4
    Sleep, 10
return


WM_KEYDOWN(wParam, lParam, nMsg, hWnd) {
	global wb
	static fields := "hWnd,nMsg,wParam,lParam,A_EventInfo,A_GuiX,A_GuiY"
	WinGetClass, ClassName, ahk_id %hWnd%
	if (ClassName = "Internet Explorer_Server") {	
		; http://www.autohotkey.com/community/viewtopic.php?p=562260#p562260
		pipa := ComObjQuery(wb, "{00000117-0000-0000-C000-000000000046}")
		VarSetCapacity(kMsg, 48)
		Loop Parse, fields, `,
			NumPut(%A_LoopField%, kMsg, (A_Index-1)*A_PtrSize)
		; Loop 2 ; only necessary for Shell.Explorer Object
			r := DllCall(NumGet(NumGet(1*pipa)+5*A_PtrSize), "ptr",pipa, "ptr",&kMsg)
		ObjRelease(pipa)
		if r = 0 ; S_OK: the message was translated to an accelerator.
			return 0
	}
}


Crawl:
Gui,Submit,nohide
result := RegExMatch(HomeURL,"(http://(.*)\.5d6d\.net/)archiver/", b5d6d_)
if !result
{
	MsgBox, 这个并非5d6d论坛Archiver压缩档网址，请核实输入的网址
}
else
{
	baseurl = %b5d6d_1% ;http://fable.5d6d.net/
	htmlpath = %b5d6d_2% ;fable
	IfNotExist, %htmlpath%
	{
		FileCreateDir, %htmlpath%
	}
	;-----
	;抓取首页，分析论坛版块
	;-----
		fpos := 1
		ToolTip, 正在后台爬行采集中，请勿重复点击“开始爬行并采集”按钮，耐心等待直至弹出完成窗口后退出本程序
		SetTimer, RemoveToolTip, 5000
		URLDownloadToFile, %HomeURL%, homeurl
		FileRead,url, homeurl
		FileDelete, homeurl
		FileDelete,index.txt
		FileDelete, %htmlpath%/index.html
		Loop
		{
			fpos := RegExMatch(url, "simU)<a\shref=""(archiver/(fid-(\d+)\.html))"">(.*)</a>" ,res_ ,fpos)
			if !fpos
				break
			fpos++
			if !res_
			{
			}
			else
			{
				FileAppend, %baseurl%%res_1%`r`n, index.txt ;版块入口文件
			}
		}
		StringReplace, url, url, <base href="%baseurl%" />, ,All
		StringReplace, url, url, href="archiver/", href="index.html",All
		StringReplace, url, url, href="bbs.php", href="%baseurl%bbs.php", All
		newhtml := RegExReplace(url,"simU)(archiver/(fid-(\d+)\.html))","$2")
		FileAppend,%newhtml%,%htmlpath%/index.html ;写入首页
		;-----
		;抓取首页，分析论坛版块内容
		;-----		
		
		;-----
		;抓取版块页面，分析该版块下帖子链接
		;-----
		Loop
		{
			FileReadLine, line, index.txt, %A_Index%
			if ErrorLevel
				break
			IfExist, get_fid.exe
				RunWait, get_fid.exe %line% %htmlpath%, %A_scriptdir%, Max UseErrorLevel
			else
				MsgBox , 缺少组件程序get_fid.exe
		}
		FileDelete,index.txt
		MsgBox, 采集完成，感想您的耐心等待
		Run, %htmlpath%/index.html
	
	/*
	else
	{
		MsgBox, 已存在 %htmlpath% 目录，为保证采集的正确性，请重命名或删除该目录后，重新点击“开始爬行并采集”按钮
	}
	*/

}

return


RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

Fresh:
Gui,Submit,nohide
WB.Silent := true
WB.Navigate(HomeURL)
return


GuiClose:
Gui, Destroy
ObjRelease(pipa)
ExitApp