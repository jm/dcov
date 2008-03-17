dcov -- Your friendly neighborhood Ruby documentation analyzer
==============================================================

dcov is a tool to analyze your Ruby documentation.  At this time, it only checks for coverage and not quality (even though it will check for that one day...).

To use dcov, you simply invoke the command from your terminal/command prompt, followed by a list of files to analyze:

  dcov my_file.rb your_file.rb

That will spit out a file named coverage.html in the current directory (more formats such as plaintext and PDF to come), which contains information about your documentation coverage.


