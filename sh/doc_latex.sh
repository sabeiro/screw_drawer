makeindex Fiziko.idx
latex Fiziko.tex && \
dvips Fiziko.dvi -o Fiziko.ps && \
psbook Fiziko.ps Fiziko.book.ps && \
psnup -2 Fiziko.book.ps Fiziko.book.2.ps && \
dvipdf Fiziko.dvi
