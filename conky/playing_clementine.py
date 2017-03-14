#!/usr/bin/env python2
#-*- coding: ascii -*-
#
# playing_clementine.py
# Script creer sur la base de anowplaying.py
# par Didier-T
#
# pour utilisation avec conky
#

import dbus, optparse, shutil, commands
import unicodedata
import math
from time import sleep


class maj:
    def __init__(self):
        '''Get system bus'''
        bus = dbus.SessionBus()
        try:
            self.amarok = bus.get_object('org.mpris.MediaPlayer2.clementine', '/org/mpris/MediaPlayer2')
        except:
            self.amarok=None
            return
        self.amarokdict = self.amarok.Get('org.mpris.MediaPlayer2.Player', 'Metadata', dbus_interface='org.freedesktop.DBus.Properties')
        self.holdtitle=""
        self.holdcover=""

    def unaccent(self, str):
        return unicodedata.normalize('NFKD', str).encode('ascii', 'ignore')

    def init_ok(self):
        if self.amarok is not None:
            return 0
        else:
            return 1

    def maj(self):
        temp = {}
        ret = {}
        cpos = mt = mtime = etime = rtime = progress = None

        if self.amarokdict.has_key('mpris:length'):
            try :
                cpos = self.amarok.Get('org.mpris.MediaPlayer2.Player', 'Position', dbus_interface='org.freedesktop.DBus.Properties')/1000000
            except:
                self.amarok=None
                return

            mt = self.amarokdict['mpris:length']/1000000
            mtime = str(mt/60)+":"+str(mt%60) if mt%60>9 else str(mt/60)+":0"+str(mt%60)
            etime = str(cpos/60)+":"+str(cpos%60) if cpos%60>9 else str(cpos/60)+":0"+str(cpos%60)
            rtime = str((mt-cpos)/60)+":"+str((mt-cpos)%60) if (mt-cpos)%60>9 else str((mt-cpos)/60)+":0"+str((mt-cpos)%60)
            progress= int(float(cpos)/float(mt)*100)

        if etime is not None:
            temp["etime"]=etime
        if rtime is not None:
            temp["rtime"]=rtime
        if mtime is not None:
            temp["mtime"]=mtime
        if progress is not None:
            temp["progress"]=progress

        try :
            self.amarokdict = self.amarok.Get('org.mpris.MediaPlayer2.Player', 'Metadata', dbus_interface='org.freedesktop.DBus.Properties')
        except:
            self.amarok=None
            return

        if self.amarokdict.has_key('xesam:artist'):
            ret["artist"] = self.unaccent(self.amarokdict['xesam:artist'][0][0:40])
        if self.amarokdict.has_key('xesam:title'):
            ret["title"] = self.unaccent(self.amarokdict['xesam:title'][0:40])
        else :
            ret["title"] = self.holdtitle
        if self.amarokdict.has_key('xesam:album'):
            ret["album"] = self.unaccent(self.amarokdict['xesam:album'][0:35])
        if self.amarokdict.has_key('xesam:genre'):
            ret["genre"] = self.unaccent(self.amarokdict['xesam:genre'][0][0:40])
        if self.amarokdict.has_key('year'):
            ret["year"] = str(self.amarokdict['year'])
        if self.amarokdict.has_key('xesam:trackNumber'):
            ret["tracknumber"] = str(self.amarokdict['xesam:trackNumber'])
        if self.amarokdict.has_key('bitrate'):
            ret["bitrate"] = str(self.amarokdict['bitrate'])
        if self.amarokdict.has_key('audio-samplerate'):
            ret["samplerate"] = str(self.amarokdict['audio-samplerate'])

        if self.amarokdict.has_key('mpris:artUrl'):
            cover = self.amarokdict['mpris:artUrl']
            if cover != "" and self.holdcover != cover :
                self.holdcover=cover
                try :
                    shutil.copyfile(cover.replace('file://', ''), "/home/sebastien/.conky/jaquet.jpg")
                except Exception, e:
                    print e

        if self.holdtitle != ret["title"] :
            self.holdtitle = ret["title"]
            fiche = open("/home/sebastien/.conky/data_clem_piste", "w")
            fiche.write(str(ret))
            fiche.close()

        fiche = open("/home/sebastien/.conky/data_clem_temps", "w")
        fiche.write(str(temp))
        fiche.close()


def demonise(init):
    x=0
    while 1 :
        '''Check if clementine is running'''
        output = commands.getoutput('ps -A')
        if 'clementine' in output:
            if init==1 :
                miseajour=maj()
                init=miseajour.init_ok()
            else:
                init=miseajour.init_ok()
                if init==0:
                    miseajour.maj()

        sleep(1)


if __name__ == '__main__':
    demonise(1)
