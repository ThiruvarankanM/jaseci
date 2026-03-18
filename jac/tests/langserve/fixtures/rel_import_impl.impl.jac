"""Implementation of run_lang_server.

Uses MyServer from the parent's relative import.
Before fix: server type = Unknown, E1032 fires on server.feature().
After fix: server type = MyServer, no errors.
"""

impl run_lang_server -> None {
    server = MyServer();
    server.feature("doc/open");
}
