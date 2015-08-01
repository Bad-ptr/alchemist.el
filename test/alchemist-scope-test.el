;;; alchemist-scope-test.el ---

;; Copyright © 2015 Samuel Tonini
;;
;; Author: Samuel Tonini <tonini.samuel@gmail.com>

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'test-helper)

(ert-deftest test-inside-string-p ()
  (should (with-temp-buffer
            (alchemist-mode)
            (insert "
defmodule Module.Name do

  @moduledoc \"\"\"
  ## Examples

  ....
  \"\"\"

end")
            (goto-line-non-inter 7)
            (alchemist-scope-inside-string-p)))
  (should (not (with-temp-buffer
                 (alchemist-mode)
                 (insert "
defmodule Module.Name do

  @moduledoc \"\"\"
  ## Examples

  ....
  \"\"\"

end")
                 (goto-line-non-inter 3)
                 (alchemist-scope-inside-string-p)))))

(ert-deftest test-inside-module-p ()
  (should (with-temp-buffer
            (alchemist-mode)
            (insert "
defmodule Foo do

end")
            (goto-line-non-inter 3)
            (alchemist-scope-inside-module-p)))
  (should (not (with-temp-buffer
                 (alchemist-mode)
                 (insert "

defmodule Foo do

end")
                 (goto-line-non-inter 2)
                 (alchemist-scope-inside-module-p)))))

(ert-deftest test-aliases-from-current-module ()
  (should (equal (list '("Phoenix.Router.Scope" "Scope")
                       '("Phoenix.Router.Resource" "Special"))
                 (with-temp-buffer
                   (alchemist-mode)
                   (insert "
defmodule Phoenix.Router do

  alias Phoenix.Router.Resource, as: Special
  alias Phoenix.Router.Scope

  @doc false
  defmacro scope(path, options, do: context) do
    options = quote do
      path = unquote(path)
      case unquote(options) do
        alias when is_atom(alias) -> [path: path, alias: alias]
        options when is_list(options) -> Keyword.put(options, :path, path)
      end
    end
    do_scope(options, context)
  end

end")
                   (alchemist-scope-aliases)))))

(ert-deftest test-scope-module ()
  (should (equal "Phoenix.Router"
                 (with-temp-buffer
                   (alchemist-mode)
                   (insert "
defmodule Phoenix.Router do

  defmacro scope(path, options, do: context) do
    options = quote do
      path = unquote(path)
      case unquote(options) do
        alias when is_atom(alias) -> [path: path, alias: alias]
        options when is_list(options) -> Keyword.put(options, :path, path)
      end
    end
    do_scope(options, context)
  end

end")
                   (goto-line-non-inter 6)
                   (alchemist-scope-module)))))

(ert-deftest test-scope-module/skip-heredoc ()
  (should (equal "Module.Name"
                 (with-temp-buffer
                   (alchemist-mode)
                   (insert "
defmodule Module.Name do

  @moduledoc \"\"\"
  ## Examples

  Phoenix defines the view template at `web/web.ex`:

      defmodule YourApp.Web do
        def view do
          quote do
            use Phoenix.View, root: \"web/templates\"

            # Import common functionality
            import YourApp.Router.Helpers

            # Use Phoenix.HTML to import all HTML functions (forms, tags, etc)
            use Phoenix.HTML
          end
        end

        # ...
      end
  \"\"\"

end")
                   (goto-line-non-inter 12)
                   (alchemist-scope-module)))))

(ert-deftest test-scope-module/nested-modules ()
  (should (equal "Inside"
                 (with-temp-buffer
                   (alchemist-mode)
                   (insert "
defmodule Outside do
  defmodule Inside do

  end
end")
                   (goto-line-non-inter 4)
                   (alchemist-scope-module)))))

(ert-deftest test-scope-use-modules ()
  (should (equal '("GenServer" "Behaviour")
                 (with-temp-buffer
                   (alchemist-mode)
                   (insert "
defmodule Phoenix.Router do

  use GenServer
  use Behaviour

end")
                   (goto-line-non-inter 6)
                   (alchemist-scope-use-modules)))))

(ert-deftest test-scope-use-modules/nested-modules ()
  (should (equal '("Macro" "Nice.Macro")
                 (with-temp-buffer
                   (alchemist-mode)
                   (insert "
defmodule Phoenix.Router do

  use GenServer
  use Behaviour

  defmodule Parser do

    use Macro
    use Nice.Macro
  end

end")
                   (goto-line-non-inter 12)
                   (alchemist-scope-use-modules)))))

(ert-deftest test-scope-import-modules ()
  (should (equal '("Test" "ExUnit")
                 (with-temp-buffer
                   (alchemist-mode)
                   (insert "
defmodule Phoenix.Router do

  import Test
  import ExUnit
  import Mix.Generator

end")
                   (goto-line-non-inter 6)
                   (alchemist-scope-import-modules)))))

(ert-deftest test-scope-import-modules/nested-modules ()
  (should (equal '("Love")
                 (with-temp-buffer
                   (alchemist-mode)
                   (insert "
defmodule Phoenix.Router do

  import Test
  import ExUnit

  defmodule Parser do

    import Love

  end

end")
                   (goto-line-non-inter 10)
                   (alchemist-scope-import-modules)))))

(provide 'alchemist-scope-test)

;;; alchemist-scope-test.el ends here
