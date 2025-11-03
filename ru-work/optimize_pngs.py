import sys, os, os.path as path, subprocess

path_tries = [path.join(path.dirname(__file__), "oxipng.exe"), "C:\\dev\\oxipng.exe"]
for oxipng_path in path_tries:
	if path.exists(oxipng_path): break
else:
	print("Нет oxipng.exe. Проверяемые пути:\n" + "\n".join(path_tries))
	sys.exit()

for base, folders, files in os.walk(path.normpath(path.join(path.dirname(__file__), "..\\ru-root\\Graphics"))):
	for file_rel in files:
		if not file_rel.endswith(".png"): continue
		subprocess.run([oxipng_path, '-o6'] + (['-Z'] if '-noZ' not in sys.argv[1:] else []) + [path.join(base, file_rel)])