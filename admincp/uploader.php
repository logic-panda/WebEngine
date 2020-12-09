<?php

if (isset($_GET['install_template'])) {
	function extractTemplateFromRar($filepath) {
		try {
			$archive = RarArchive::open($filepath);
			$entries = $archive->getEntries();
			$extract_dir = '/var/www/html/templates';

			foreach ($entries as $entry) {
			    $entry->extract($extract_dir);
			}

			$archive->close();
		} catch (\Throwable $th) {
			throw $th;
		}
	}

	function uploadTemplate($uploaded) {
		$target_dir = "/var/www/uploads/";
		$target_file = $target_dir . basename($uploaded["name"]);
		$fileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));

		try {
			if($fileType != "rar") {
				throw new Exception("Sorry, only RAR file are allowed.");
			}

			// Check if file already exists
			if (file_exists($target_file)) {
				throw new Exception("Sorry, file already exists.");
			}

			if (move_uploaded_file($uploaded["tmp_name"], $target_file)) {
				extractTemplateFromRar($target_file);
				unlink($target_file);
			} else {
				throw new Exception("Sorry, there was an error uploading your file.");
			}
		} catch(\Throwable $th) {
			throw $th;
		}
	}

	if (isset($_FILES['templatefile'])) {
		try {
			uploadTemplate($_FILES['templatefile']);
			echo "Template instalado com sucesso!";
		} catch (\Throwable $th) {
			echo $th;
		}
	}

}
