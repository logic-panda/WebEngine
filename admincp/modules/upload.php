<?php

if (isset($_GET['install_template'])) {
	define('__ROOT_DIR__', str_replace('\\','/',dirname(dirname(__FILE__))).'/');
	define('__PATH_TEMPLATES__', __ROOT_DIR__.'templates/');

	function extractTemplateFromRar($filepath) {
		try {
			$rar_file = rar_open($filepath);
			$list = rar_list($rar_file);

			foreach($list as $file) {
					$entry = rar_entry_get($rar_file, $file);
					$entry->extract(__PATH_TEMPLATES__);
			}

			rar_close($rar_file);
		} catch (\Throwable $th) {
			throw $th;
		}
	}

	function uploadTemplate($uploaded) {
		$tmp_name = $uploaded["tmp_name"];
		$name = basename($uploaded["name"]);
		$path_parts = pathinfo($name);

		try {
			if (strtolower($path_parts['extension']) != "rar") {
				throw new Exception('Invalid uploaded type, only rar is allowed.');
			}

			move_uploaded_file($tmp_name, "/tmp/$name");

			extractTemplateFromRar("/tmp/$name");
		} catch(\Throwable $th) {
			throw $th;
		}
	}

	if (isset($_FILES['templatefile'])) {
		uploadTemplate($_FILES['templatefile']);
	}

}
