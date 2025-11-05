{$mode objfpc} {$longstrings on} {$modeswitch anonymousfunctions} {$modeswitch duplicatelocals} {$coperators+} {$zerobasedstrings+}
{$macro on}

{$ifdef Debug}
	{$define dline := writeln}
	{$apptype console}
{$else}
	{$define dline := //}
	{$apptype gui}
{$endif}

{$R *.res}

{$warn 4055 off: Conversion between ordinals and pointers is not portable}
{$warn 5024 off: Parameter not used}
{$warn 5057 off: Local variable does not seem to be initialized}
{$warn 5058 off: Local variable does not seem to be initialized}
{$warn 5090 off: Variable of a managed type does not seem to be initialized}

uses
	Windows;

var
	qpf: int64;

	function QPC: int64; inline;
	begin
		QueryPerformanceCounter(result);
	end;

type
	Fail = class
	const
		Silent = dword(-1);
	var
		msg: string;
		err: dword;
		procedure Show;
		class procedure Throw(const msg: string; err: dword = 0); static;
		class procedure Silently; static;
	end;

	procedure Fail.Show;
	var
		wmsg: unicodestring;
		buf: pUnicodeChar;
		nBuf: SizeUint;
	begin
		wmsg := UTF8Decode(msg);
		if err <> 0 then
		begin
			nBuf := FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_ALLOCATE_BUFFER, nil, err, 0, pUnicodeChar(@buf), 0, nil);
			if nBuf > 0 then
				try
					wmsg := wmsg + LineEnding + unicodestring(buf);
				finally
					LocalFree(HLOCAL(buf));
				end;
		end;
		MessageBoxW(0, pointer(wmsg), nil, MB_OK or MB_ICONERROR);
	end;

	class procedure Fail.Throw(const msg: string; err: dword = 0);
	var
		e: Fail;
	begin
		e := Fail.Create;
		e.msg := msg;
		e.err := err;
		raise e;
	end;

	class procedure Fail.Silently;
	begin
		Throw('', Silent);
	end;

	function UTF8Encode(const s: unicodestring): string;
	begin
		result := System.UTF8Encode(s);
		SetCodePage(rawbytestring(result), CP_ACP, false);
	end;

{$ifdef Debug}
	function RectStr(const r: RECT): string;
	begin
		WriteStr(result, r.Left, ' ', r.Top, ' ', r.Right, ' ', r.Bottom, ' (', r.Right - r.Left, ' x ', r.Bottom - r.Top, ')');
	end;
{$endif}

	function AdjustGameWindowSize(gameWindow: HWND; const desktopRect: RECT): boolean;
	const
		OrigW = 640;
		OrigH = 480;
	var
		wr, dCli: RECT;
		maxSizeX, maxSizeY, scale, scaleY, dSizeX, dSizeY: int32;
		i: SizeInt;
		style: PtrUint;
	begin
		result := false;
		if not GetWindowRect(gameWindow, wr) then Fail.Silently;
		style := GetWindowLongPtrW(gameWindow, GWL_STYLE);
		// Это 100% поломает аспект, если пользователь реально будет растягивать окно, но может быть его последним шансом хоть как-то это сделать...
		if (style <> 0) and (style and WS_SIZEBOX = 0) then
		begin
			style := style or WS_SIZEBOX;
			SetWindowLongPtrW(gameWindow, GWL_STYLE, style or WS_SIZEBOX);
			dline('WS_SIZEBOX added to style.');
			result := true;
		end;
		FillChar(dCli, sizeof(dCli), 0);
		if not AdjustWindowRect(dCli, style, false) then Fail.Silently;
		for i := 0 to 3 do pInt32(@wr)[i] -= pInt32(@dCli)[i];

		maxSizeX := desktopRect.Right - desktopRect.Left - (dCli.Right - dCli.Left);
		maxSizeY := desktopRect.Bottom - desktopRect.Top - (dCli.Bottom - dCli.Top);
		if (maxSizeX <= 0) or (maxSizeY <= 0) then exit;
		// Если окно достаточного размера или, наоборот, слишком маленькое, ничего не делать.
		if (wr.Right - wr.Left < 1) or (wr.Bottom - wr.Top < 1) then exit;

		scale := uint32(maxSizeX) div OrigW;
		scaleY := uint32(maxSizeY) div OrigH;
		if scale > scaleY then scale := scaleY;
		if scale <= 1 then exit;
		dSizeX := scale * OrigW - (wr.Right - wr.Left);
		dSizeY := scale * OrigH - (wr.Bottom - wr.Top);
		if (dSizeX <= 0) or (dSizeY <= 0) then exit;
		dline('Window client rect: ', RectStr(wr), ', non-client margin: ', RectStr(dCli), '.');
		wr.Left -= (dSizeX + 1) div 2;
		wr.Right += dSizeX div 2;
		wr.Top -= (dSizeY + 1) div 2;
		wr.Bottom += dSizeY div 2;

		for i := 0 to 3 do pInt32(@wr)[i] += pInt32(@dCli)[i];
		if SetWindowPos(gameWindow, 0, wr.Left, wr.Top, wr.Right - wr.Left, wr.Bottom - wr.Top, SWP_NOZORDER or SWP_FRAMECHANGED) then
		begin
			dline('SetWindowPos to ', RectStr(wr), '.');
			result := true;
		end;
	end;

var
	path: unicodestring;
	si: STARTUPINFOW;
	pi: PROCESS_INFORMATION;
	nPath, err, nAdjusts: uint32;
	gameWindow: HWND;
	desktopRect: RECT;
	lastAdjust: int64;

begin
	DefaultSystemCodePage := CP_ACP;
	QueryPerformanceFrequency(qpf);
	FillChar(pi, sizeof(pi), 0);
	try try
		repeat
			SetLength(path, 256 + SizeUint(length(path)) div 2);
			nPath := GetModuleFileNameW(HInstance, pointer(path), length(path));
			if nPath = 0 then Fail.Throw('Не удалось получить имя файла игры.');
		until nPath < SizeUint(length(path));
		nPath := length(path);
		while (nPath > 0) and (path[nPath - 1] <> '\') and (path[nPath - 1] <> '/') do nPath -= 1;
		path := Copy(path, 1, nPath) + 'Game.exe';

		FillChar(si, sizeof(si), 0);
		si.cb := sizeof(si);
		if not CreateProcessW(pointer(path), nil, nil, nil, false, 0, nil, pUnicodeChar(Copy(path, 1, nPath)), si, pi) then
		begin
			err := GetLastError;
			Fail.Throw('Не удалось запустить ' + UTF8Encode(path) + '.', err);
		end;

		if WaitForInputIdle(pi.hProcess, INFINITE) <> 0 then Fail.Silently;
		gameWindow := 0;
		EnumWindows(
			function(h: HWND; param: LPARAM): WINBOOL stdcall
			var
				pid: dword;
				rct: RECT;
			begin
				result := true;
				if (GetWindowThreadProcessId(h, pid) <> 0) and (pid = pi.dwProcessId) and
					GetWindowRect(h, rct) and (rct.Right - rct.Left > 0) and (rct.Bottom - rct.Top > 0)
				then
				begin
					// Просто предполагаем, что первое окно ненулевого размера и есть искомое.
					// Не факт, что сработает, но у меня окно игры всегда первое в принципе, с размером просто перестраховка.
					gameWindow := h;
					exit(false);
				end;
			end, 0);
		if gameWindow = 0 then Fail.Silently;

		if not GetWindowRect(GetDesktopWindow, desktopRect) then Fail.Throw('Не удалось получить размер рабочего стола.');
		dline('Desktop rect: ', RectStr(desktopRect), '.');

		nAdjusts := 0;
		repeat
			if AdjustGameWindowSize(gameWindow, desktopRect) then
			begin
				lastAdjust := QPC;
				nAdjusts += 1;
				if nAdjusts >= 3 then
				begin
					// Если размер изменён уже больше трёх раз (ну, у меня где-то столько меняется), наверное, всё хорошо.
					dline('Done (succeed 3 times).'); readln;
					exit;
				end;
			end
			else if (nAdjusts > 0) and (QPC - lastAdjust >= 5 * qpf) then
			begin
				// Если размер не менялся уже 5 секунд, наверное, всё хорошо.
				dline('Done (nothing to do for 5 seconds).'); readln;
				exit;
			end;
			Sleep(100);
		until false;
	finally
		if pi.hThread <> 0 then CloseHandle(pi.hThread);
		if pi.hProcess <> 0 then CloseHandle(pi.hProcess);
	end except
		on e: Fail do
			if e.err <> e.Silent then e.Show;
	end;
{$ifdef Debug} readln; {$endif}
end.

