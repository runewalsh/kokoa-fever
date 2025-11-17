import os, os.path as path, argparse, subprocess, shutil
from contextlib import suppress

ap = argparse.ArgumentParser()
ap.add_argument('game_inout', help="Папка с игрой.", metavar='путь_к_игре')
ap.add_argument('--tl', help="Перевести игру. Также выполняется по умолчанию, если не задано другой работы.", action='store_true')
ap.add_argument('--pngs', help="Оптимизировать PNG (нужен oxipng).", action='store_true')
ap.add_argument('--pngZ', help="Оптимизировать PNG сильнее (oxipng -Z); очень медленно.", action='store_true')
ap.add_argument('--wavs', help="Оптимизировать WAV (нужен ffmpeg).", action='store_true')
args = ap.parse_args()

repo = path.dirname(__file__)
game_inout = path.abspath(args.game_inout)

def link_or_copy(src, dst):
	with suppress(OSError):
		os.remove(dst)
	try:
		os.link(src, dst)
	except OSError:
		shutil.copy(src, dst)

def rebase_path(src, src_base, dst_base):
	return path.join(dst_base, path.relpath(src, src_base))

if not path.exists(game_inout):
	raise RuntimeError("Папка с игрой (" + game_inout + ") не существует.")
if not path.exists(path.join(game_inout, 'Game.exe')):
	raise RuntimeError("Папка с игрой (" + game_inout + ") не выглядит как папка с игрой.")

if args.tl or not (args.pngs or args.pngZ or args.wavs):
	subprocess.run([path.join(repo, 'VXAceTranslator\\VXAceTranslator.exe'), '-c', game_inout, '-i', path.join(repo, 'ru-decompiled')])

	ru_root = path.join(repo, 'ru-root')

	for base, folders, files in os.walk(ru_root):
		for folder_rel in folders:
			with suppress(OSError):
				os.mkdir(rebase_path(path.join(base, folder_rel), ru_root, game_inout))
		for file_rel in files:
			file_full = path.join(base, file_rel)
			link_or_copy(file_full, rebase_path(file_full, ru_root, game_inout))

	wipe_folders = \
	[
		#'パッチノート',
		#'開発メモ\\メモです',
		#'開発メモ',
	]

	for folder_rel in wipe_folders:
		folder_full = path.join(game_inout, folder_rel)
		with suppress(OSError):
			for file in os.scandir(folder_full):
				with suppress(OSError):
					os.remove(file.path)
		with suppress(OSError):
			os.rmdir(folder_full)

	wipe_files = \
	[
		'error_log20140109.txt',
		#'能力値について.txt',
		#'頂いた素材.txt',
		'Game.rgss3a',
		'Game.rgss3a.old',
		'Graphics\\Pictures.zip'
	]

	for file_rel in wipe_files:
		with suppress(OSError):
			os.remove(path.join(game_inout, file_rel))

	with suppress(OSError):
		os.rename(path.join(game_inout, "###こまめにセーブ###.txt"), path.join(game_inout, "### Сохраняйтесь почаще ###.txt"))

	with suppress(OSError):
		link_or_copy(path.join(repo, "scaled\\bin\\Game (scaled).exe"), path.join(game_inout, "Game (scaled).exe"))

def search_executable(name, base_tries):
	for base in base_tries:
		if path.exists(full := path.join(base, name)):
			return full
	print("Нет " + name + ". Проверяемые пути:\n" + "\n".join(path.join(base, name) for base in base_tries))

if (args.pngs or args.pngZ) and (oxipng_path := search_executable("oxipng.exe", [repo, "C:\\dev"])):
	for base, folders, files in os.walk(path.join(game_inout, "Graphics")):
		for file_rel in files:
			if not file_rel.endswith(".png"): continue
			subprocess.run([oxipng_path, '--strip', 'all', '-o6'] + (['-Z'] if args.pngZ else []) + [path.join(base, file_rel)])

if args.wavs and (ffmpeg_path := search_executable("ffmpeg.exe", [repo])):
	for old_fn_rel in ["Audio\\BGM\\04_Dance With Neo Age.wav"]:
		old_fn = path.join(game_inout, old_fn_rel)
		if not path.exists(old_fn): continue
		new_fn = path.join(game_inout, path.splitext(old_fn)[0] + ".mp3")
		subprocess.run([ffmpeg_path, '-y', '-i', old_fn, '-c:a', 'libmp3lame', '-b:a', '320k', new_fn])
		if path.exists(new_fn):
			os.replace(old_fn, new_fn)
		else:
			print("Не удалось преобразовать " + old_fn + ".")