from os import path

import sublime
import sublime_plugin


SUPPORTED_EXTENSIONS = ['.py']


class CopyPythonPathCommand(sublime_plugin.TextCommand):
    def _is_package(self, package_path):
        for extension in SUPPORTED_EXTENSIONS:
            file_name = path.join(package_path, '__init__' + extension)
            if path.exists(file_name):
                return True
        return False

    def run(self, edit):
        file_path = self.view.file_name()
        file_base_name = file_path.split('/')[-1].rstrip('.py')
        package = []

        if file_base_name != '__init__':
            package.append(file_base_name)

        package_path = path.dirname(file_path)
        while self._is_package(package_path):
            package.append(path.basename(package_path))
            package_path, old_path = path.dirname(package_path), package_path
            if package_path == old_path:
                break

        if len(package) > 0:
            python_path = '.'.join(reversed(package))
            sublime.set_clipboard(python_path)
            sublime.status_message("Copied python path {}".format(python_path))

    def is_enabled(self):
        file_extension = '.' + self.view.file_name().split('.')[-1]
        return file_extension in SUPPORTED_EXTENSIONS
