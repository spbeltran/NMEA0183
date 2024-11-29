## ========================================
## Makefile configuration
## ========================================

-include config.mk

## Default options
all						:	# The canonical default target.
COMPILER				?=	gcc
BUILD					?=	debug
DESTDIR					?=	.

## ========================================
## Functions
## ========================================

## Recursive wildcard
r_wildcard				=	$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call r_wildcard,$d/,$2))

## Relative path
relpath					=	$(1:$(CURDIR)/%=./%)

## Create a target to install a certain file: File $1 will be installed on path $2
t_install_file			=	$1 : $(subst $3,$2,$1) ; @ echo "Installing $$<"; mkdir -p $$(dir $$@); install $$< $$@

## ==========================================================
## Configuration
## ==========================================================

## Configuration
CXX.gcc					=	/bin/g++
CC.gcc					=	/bin/gcc
LD.gcc					=	/bin/g++
AR.gcc					=	/bin/ar
RM.gcc					=	/bin/rm
CMAKE.gcc				=	/bin/cmake
TOUCH.gcc				=	/bin/touch
INSTALL.gcc				=	/bin/install

CXX						=	$(CXX.$(COMPILER))
CC						=	$(CC.$(COMPILER))
LD						=	$(LD.$(COMPILER))
AR						=	$(AR.$(COMPILER))
RM						=	$(RM.$(COMPILER))
CMAKE					=	$(CMAKE.$(COMPILER))
TOUCH					=	$(TOUCH.$(COMPILER))
INSTALL					=	$(INSTALL.$(COMPILER))

CXXFLAGS.gcc			=	-std=c++17 -Wall -Wextra -Werror -Wpedantic
CXXFLAGS.gcc.debug		=	-O0 -ggdb -D_DEBUG
CXXFLAGS.gcc.release	=	-O3 -g0   -DNDEBUG
CXXFLAGS.gcc.shared		=	-fPIC
CXXFLAGS.gcc.static		=

CXXFLAGS.static			=	$(CXXFLAGS.$(COMPILER)) $(CXXFLAGS.$(COMPILER).$(BUILD)) $(CXXFLAGS.$(COMPILER).static)
CXXFLAGS.shared			=	$(CXXFLAGS.$(COMPILER)) $(CXXFLAGS.$(COMPILER).$(BUILD)) $(CXXFLAGS.$(COMPILER).shared)

DEPFLAGS				=	-MT $@ -MMD -MP -MF $(path_build_dep)/$*.d
INCFLAGS				=	-I $(path_include) -isystem $(path_build_include)
LDFLAGS					=	-L $(path_build_lib) -Wl,-rpath,'$$ORIGIN'/../lib
LDLIBS					=	$(addprefix -l,$(foreach x,$(goals:%=%.name),$($x)) $(foreach x,$(libs:%=%.name),$($x)))

TOUCH.FILE.msg			=
PREPROCESS.CXX.msg		=	echo "Processing C++ '$(call relpath,$<)'      ";
COMPILE.CXX.msg			=	echo "Compiling C++  '$(call relpath,$<)'      ";
PREPROCESS.CXX.SO.msg	=	echo "Processing C++ '$(call relpath,$<)' [PIC]";
COMPILE.CXX.SO.msg		=	echo "Compiling C++  '$(call relpath,$<)' [PIC]";
LINK.EXE.msg			=	echo "Linking to exe '$(call relpath,$@)'      ";
LINK.SO.msg				=	echo "Linking to lib '$(call relpath,$@)'      ";
LINK.A.msg				=	echo "Compressing to '$(call relpath,$@)'      ";
INSTALL.FILE.msg		=	echo "Installing     '$(call relpath,$<)'      ";
CLEAN.FILE.msg			=	$(if $(wildcard $*),echo -n "Removing file ",echo -n "File not found "); echo "'$(call relpath,$*)'";
CLEAN.DIR.msg			=	$(if $(wildcard $*),echo -n "Removing dir " ,echo -n "Dir not found " ); echo "'$(call relpath,$*)'";

TOUCH.FILE.pre			=	mkdir -p $(dir $@);
PREPROCESS.CXX.pre		=	mkdir -p $(dir $@);
COMPILE.CXX.pre			=	mkdir -p $(dir $@) $(path_build_dep)/$(dir $*);
PREPROCESS.CXX.SO.pre	=	mkdir -p $(dir $@);
COMPILE.CXX.SO.pre		=	mkdir -p $(dir $@) $(path_build_dep)/$(dir $*);
LINK.EXE.pre			=	mkdir -p $(dir $@);
LINK.SO.pre				=	mkdir -p $(dir $@);
LINK.A.pre				=	mkdir -p $(dir $@);
INSTALL.FILE.pre		=	mkdir -p $(dir $@);
CLEAN.FILE.pre			=
CLEAN.DIR.pre			=

TOUCH.FILE.act			=	$(TOUCH)          $@;
PREPROCESS.CXX.act		=	$(CXX) -E      -o $@ ${CXXFLAGS.static} $(INCFLAGS)             $(abspath $<);
COMPILE.CXX.act			=	$(CXX) -c      -o $@ ${CXXFLAGS.static} $(INCFLAGS) $(DEPFLAGS) $(abspath $<);
PREPROCESS.CXX.SO.act	=	$(CXX) -E      -o $@ ${CXXFLAGS.shared} $(INCFLAGS)             $(abspath $<);
COMPILE.CXX.SO.act		=	$(CXX) -c      -o $@ ${CXXFLAGS.shared} $(INCFLAGS) $(DEPFLAGS) $(abspath $<);
LINK.EXE.act			=	$(LD)          -o $@ ${CXXFLAGS.static} $(LDFLAGS) $(filter %.o,$^) $(LDLIBS);
LINK.SO.act				=	$(LD)  -shared -o $@ ${CXXFLAGS.shared}            $(filter %.o,$^);
LINK.A.act				=	$(AR)  rsc        $@                               $(filter %.o,$^);
INSTALL.FILE.act		=	$(INSTALL)     $< $@;
CLEAN.FILE.act			=	$(RM) -f          $*;
CLEAN.DIR.act			=	$(RM) -rf         $*;

TOUCH.FILE				=	$(TOUCH.FILE.msg)			$(TOUCH.FILE.pre)			$(TOUCH.FILE.act)
PREPROCESS.CXX			=	$(PREPROCESS.CXX.msg)		$(PREPROCESS.CXX.pre)		$(PREPROCESS.CXX.act)
COMPILE.CXX				=	$(COMPILE.CXX.msg)			$(COMPILE.CXX.pre)			$(COMPILE.CXX.act)
PREPROCESS.CXX.SO		=	$(PREPROCESS.CXX.SO.msg)	$(PREPROCESS.CXX.SO.pre)	$(PREPROCESS.CXX.SO.act)
COMPILE.CXX.SO			=	$(COMPILE.CXX.SO.msg)		$(COMPILE.CXX.SO.pre)		$(COMPILE.CXX.SO.act)
LINK.EXE				=	$(LINK.EXE.msg)				$(LINK.EXE.pre)				$(LINK.EXE.act)
LINK.SO					=	$(LINK.SO.msg)				$(LINK.SO.pre)				$(LINK.SO.act)
LINK.A					=	$(LINK.A.msg)				$(LINK.A.pre)				$(LINK.A.act)
INSTALL.FILE			=	$(INSTALL.FILE.msg)			$(INSTALL.FILE.pre)			$(INSTALL.FILE.act)
CLEAN.FILE				=	$(CLEAN.FILE.msg)			$(CLEAN.FILE.pre)			$(CLEAN.FILE.act)
CLEAN.DIR				=	$(CLEAN.DIR.msg)			$(CLEAN.DIR.pre)			$(CLEAN.DIR.act)

## ==========================================================
## Setup
## ==========================================================

## Paths
path_include			:=	$(CURDIR)
path_src				:=	$(CURDIR)
path_build				:=	$(CURDIR)/build
path_build_bin			:=	$(path_build)/bin
path_build_lib			:=	$(path_build)/lib
path_build_obj			:=	$(path_build)/obj
path_build_dep			:=	$(path_build_obj)/.dep
path_build_include		:=	$(path_build)/include
path_dest				:=	$(DESTDIR)
path_dest_bin			:=	$(path_dest)/bin
path_dest_lib			:=	$(path_dest)/lib
path_dest_include		:=	$(path_dest)/include/nmea0183

## General
name					=	nmea0183
target					=	$(path_build_lib)/lib$(name).so
config					=	$(path_build)/.$(BUILD)

## ==========================================================
## Main
## ==========================================================

## nmea0183
nmea0183.path_src		:=	$(path_src)
nmea0183.path_include	:=	$(path_include)
nmea0183.target			:=	$(target)
nmea0183.cpps			=	$(wildcard $(nmea0183.path_src)/*.CPP)
nmea0183.hpps			:=	$(wildcard $(nmea0183.path_include)/*.HPP)
nmea0183.hpps			+=	$(wildcard $(nmea0183.path_include)/*.hpp)
nmea0183.hpps			+=	$(wildcard $(nmea0183.path_include)/*.h)
nmea0183.objs			:=	$(nmea0183.cpps:$(nmea0183.path_src)/%.CPP=$(path_build_obj)/%.so.o)
nmea0183.deps			:=	$(nmea0183.cpps:$(nmea0183.path_src)/%.CPP=$(path_build_dep)/%.d)
nmea0183.dest_hs		:=	$(nmea0183.hpps:$(nmea0183.path_include)/%=$(path_dest_include)/%)
nmea0183.dest_so		:=	$(nmea0183.target:$(path_build_lib)/%=$(path_dest_lib)/%)

.PHONY					:	nmea0183 nmea0183-clean
nmea0183				:	$(nmea0183.target)
$(nmea0183.target)		:	$(nmea0183.objs)
nmea0183-clean			:	$(addsuffix .clean,$(nmea0183.target) $(nmea0183.objs) $(nmea0183.deps))
nmea0183-install		:	$(nmea0183.dest_hs) $(nmea0183.dest_so)
$(foreach file,$(nmea0183.dest_hs),$(eval $(call t_install_file,$(file),$(nmea0183.path_include),$(path_dest_include))))
$(foreach file,$(nmea0183.dest_so),$(eval $(call t_install_file,$(file),$(path_build_lib),$(path_dest_lib))))
nmea0183-uninstall		:	$(addsuffix .clean,$(nmea0183.dest_hs) $(nmea0183.dest_so))

-include $(nmea0183.deps)

## ==========================================================
## Generic targets
## ==========================================================

$(path_build_obj)/%.o	:	$(CURDIR)/%.CPP			;	@ $(strip $(COMPILE.CXX))
$(path_build_obj)/%.o	:	$(path_src)/%.CPP		;	@ $(strip $(COMPILE.CXX))
$(path_build_obj)/%.so.o:	$(path_src)/%.CPP		;	@ $(strip $(COMPILE.CXX.SO))
$(path_build_lib)/%.a	:							;	@ $(strip $(LINK.A))
$(path_build_lib)/%.so	:							;	@ $(strip $(LINK.SO))
$(path_build_bin)/%.exe	:							;	@ $(strip $(LINK.EXE))
%.clean					:							;	@ $(strip $(CLEAN.FILE))
%.rclean				:							;	@ $(strip $(CLEAN.DIR))

## ==========================================================
## User targets
## ==========================================================

.PHONY					:	all fast clean distclean mrproper
all						:	$(config) $(name)		;	@ echo "Finished updating file '$(name)' in '$(BUILD)' mode."
fast					:							;	@ $(MAKE) -s -j$(n_cores) all
install					:	$(name)-install
uninstall				:	$(name)-uninstall
clean					:	$(name)-clean
distclean				:	uninstall clean
mrproper				:	distclean config.mk.clean $(path_build).rclean

$(dir $(config)).debug	:;	@ $(MAKE) -s mrproper	;	$(strip $(TOUCH.FILE))
$(dir $(config)).release:;	@ $(MAKE) -s mrproper	;	$(strip $(TOUCH.FILE))