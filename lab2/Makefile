# $Header: https://svn.ita.chalmers.se/repos/security/edu/course/computer_security/trunk/assignment/Makefile 591 2013-01-29 08:34:33Z pk@CHALMERS.SE $

MAINFILE	:= report
OUTPUT		:= 

BUILDDIR	:= build

TEXFILES	:= ${MAINFILE}.tex *.tex
FIGURES		:= figures/*.png

.PHONY: all clean new view quick

all: report

clean:
	rm -rf ${BUILDDIR}

new: clean all

report: ${BUILDDIR}/${MAINFILE}.pdf
	cp ${BUILDDIR}/${MAINFILE}.pdf ${MAINFILE}.pdf

view: report
	evince ${MAINFILE}.pdf &

quick: ${TEXFILES}
	-mkdir ${BUILDDIR}
	pdflatex -output-directory ${BUILDDIR} ${MAINFILE}.tex


${BUILDDIR}/${MAINFILE}.pdf: ${TEXFILES}
	-mkdir ${BUILDDIR}
	pdflatex -output-directory ${BUILDDIR} ${MAINFILE}.tex
	pdflatex -output-directory ${BUILDDIR} ${MAINFILE}.tex
	biber ${BUILDDIR}/${MAINFILE}
	biber ${BUILDDIR}/${MAINFILE}
	pdflatex -output-directory ${BUILDDIR} ${MAINFILE}.tex
	pdflatex -output-directory ${BUILDDIR} ${MAINFILE}.tex

