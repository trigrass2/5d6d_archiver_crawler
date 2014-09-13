/*
脚本名称：	get_fid
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
	fetch_url = %1%	;http://fable.5d6d.net/archiver/fid-5.html
	filepath = %2%	;fable
	SplitPath, fetch_url, file_name, web_dir, file_ext, save_url, domain_url
	;file_name:fid-5.html
	;web_dir:http://fable.5d6d.net/archiver
	;file_ext:html
	;save_url:fid-5
	;domain_url:http://fable.5d6d.net
	URLDownloadToFile, %fetch_url%, %save_url%
	FileRead, url, %save_url%
	FileDelete, %save_url%
	IfNotExist, %filepath%/%save_url%.html
	{
		
	;-----
	;抓取版块页面，分析该版块下帖子链接
	;-----
		FileDelete,%save_url%.txt
		FileDelete,%save_url%_tid.txt
		fpos1 := 1
		fpos2 := 1
		Loop
		{
			fpos1 := RegExMatch(url, "simU)<a\shref=(archiver/(fid-(\d+)-page-(\d+)\.html))>(.*)</a>" ,res1_ ,fpos1)
			if !fpos1
				break
			fpos1++
			if !res1_
			{
			}
			else
			{
				FileAppend, %web_dir%/%res1_2%`r`n, %save_url%.txt ;版块页面入口文件 fid-5.txt
			}
		}
		Loop
		{
			fpos2 := RegExMatch(url, "simU)<a\shref=""(archiver/(tid-(\d+)\.html))"">(.*)</a>" ,res2_ ,fpos2)
			if !fpos2
				break
			fpos2++
			if !res2_
			{
			}
			else
			{
				FileAppend, %web_dir%/%res2_2%`r`n, %save_url%_tid.txt ;版块页面tid文件 fid-5_tid
			}			
		}
		StringReplace, url, url, <base href="%domain_url%/" />, ,All
		StringReplace, url, url, href="archiver/", href="index.html",All 
		StringReplace, url, url, href="forumdisplay.php, href="%domain_url%/forumdisplay.php, All
		url := RegExReplace(url,"simU)(archiver/(fid-(\d+)\.html))","$2")
		url := RegExReplace(url,"simU)href=(archiver/(fid-(\d+)-page-(\d+)\.html))","href=""$2""")
		newhtml := RegExReplace(url,"simU)(archiver/(tid-(\d+)\.html))","$2")
		FileAppend,%newhtml%,%filepath%/%file_name% ;写入该版块下某一页面
		
		Loop
		{
			FileReadLine, line, %save_url%.txt, %A_Index%	;fid-5.txt
			if ErrorLevel
				break
			IfExist, get_fid.exe
				RunWait, get_fid.exe %line% %filepath%, %A_scriptdir%, Max UseErrorLevel
			else
				MsgBox , 缺少组件程序get_tid.exe
		}
		FileDelete, %save_url%.txt
		
		Loop
		{
			FileReadLine, line, %save_url%_tid.txt, %A_Index% ;fid-5_tid.txt
			if ErrorLevel
				break
			IfExist, get_tid.exe
				RunWait, get_tid.exe %line% %filepath%, %A_scriptdir%, Max UseErrorLevel
			else
				MsgBox , 缺少组件程序get_tid.exe
		}
		FileDelete, %save_url%_tid.txt
	}
	else
	{
		ExitApp
	}
	;-----
	;抓取版块页面，分析该版块下帖子链接
	;-----

}