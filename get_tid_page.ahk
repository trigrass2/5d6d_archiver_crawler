/*
脚本名称：	get_tid_page
脚本编码：	UTF-8(with BOM)
脚本说明：	discuz论坛压缩档爬虫组件程序
脚本版本：	1.0
脚本作者：	飞扬网络工作室 (fysoft)
作者官网：	http://raoyc.com/fysoft/
交流Q群：	260655062
运行环境：	作者在编码或测试此脚本时所使用的运行环境为 Windows XP SP3 + AutoHotkey(L) v1.1.10.01，其它相异于此运行环境的，请自行测试脚本兼容性问题
版权申明：	非商业使用，在此脚本基础上所作出的修改，需保留原作者署名信息（作者名和官网链接）
备注信息：	
*/

#NoEnv
SendMode Input 
SetWorkingDir %A_ScriptDir%
;MsgBox, %A_AhkVersion%

#SingleInstance Off
#NoTrayIcon 

if (%0% < 2)
{
	MsgBox, 调用参数错误
	ExitApp
}
else
{
	fetch_url = %1%	;http://fable.5d6d.net/archiver/tid-10511-page-2.html
	filepath = %2%	;fable
	SplitPath, fetch_url, file_name, web_dir, file_ext, save_url, domain_url
	;file_name:tid-10511-page-2.html
	;web_dir:http://fable.5d6d.net/archiver
	;file_ext:html
	;save_url:tid-10511-page-2
	;domain_url:http://fable.5d6d.net
	URLDownloadToFile, %fetch_url%, %save_url%
	FileRead, url, %save_url%
	FileDelete, %save_url%
	IfNotExist, %filepath%/%save_url%.html
	{
		
	;-----
	;抓取帖子页面，分析该帖子下分页链接
	;-----
		FileDelete, %save_url%.txt
		fpos := 1
		Loop
		{
			fpos := RegExMatch(url, "simU)<a\shref=(archiver/(tid-(\d+)-page-(\d+)\.html))>(.*)</a>" ,res_ ,fpos)
			if !fpos
				break
			fpos++
			if !res_
			{
			}
			else
			{
				FileAppend, %web_dir%/%res_2%`r`n, %save_url%.txt ;帖子页面入口文件 tid-10511-page-2
			}
		}
		StringReplace, url, url, <base href="%domain_url%/" />, ,All
		StringReplace, url, url, href="archiver/", href="index.html",All 
		StringReplace, url, url, href="viewthread.php, href="%domain_url%/viewthread.php, All
		url := RegExReplace(url,"simU)(archiver/(fid-(\d+)\.html))","$2")
		newhtml := RegExReplace(url,"simU)href=(archiver/(tid-(\d+)-page-(\d+)\.html))","href=""$2""")
		FileAppend,%newhtml%,%filepath%/%file_name% ;写入该帖子下某一页面

		IfExist, %save_url%.txt
		{
			Loop
			{
				FileReadLine, line, %save_url%.txt, %A_Index%
				if ErrorLevel
					break
				IfExist, get_tid_page.exe
					RunWait, get_tid_page.exe %line% %filepath%, %A_scriptdir%, Max UseErrorLevel
				else
					MsgBox , 缺少组件程序get_tid_page.exe
			}
			
			FileDelete, %save_url%.txt
		}
		
		
	}
	else
	{
		ExitApp
	}
	;-----
	;抓取帖子页面，分析该帖子下分页链接
	;-----
	
}