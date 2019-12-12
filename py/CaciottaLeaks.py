#!/usr/bin/env python
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

import pygtk
pygtk.require('2.0')
import gtk, pango
import time
import MySQLdb as mdb
import _mysql 
import sys

# Global variables
b_entry_checkbox = True
con = None
DbSector = "delivery"
DbCheese = "Mozz"
DbKey = "date"
ProdAv = "Average: 0"
DbDate1 = "01/01/13"
DbDate2 = "01/04/13"
#connect db
class ConnectDb:
   global con
   try:
       con = _mysql.connect('localhost', 'sabeiro','ciccia', 'cefa')
       con.query("SELECT VERSION()")
       result = con.use_result()
       print "MySQL version: %s" % \
           result.fetch_row()[0]
   except _mysql.Error, e:
       print "Error %d: %s" % (e.args[0], e.args[1])
       sys.exit(1)
   finally:
       if con:
           con.close()
       con = mdb.connect('localhost', 'sabeiro', 'ciccia', 'cefa');

class CaciottaLeaks:
    DEF_PAD = 10
    DEF_PAD_SMALL = 5
    TM_YEAR_BASE = 1900

    calendar_show_header = 0
    calendar_show_days = 1
    calendar_month_change = 2 
    calendar_show_week = 3
    Date1 = gtk.Label("")
    Date2 = gtk.Label("")

    def entry_checkbox(self, widget, checkbox):
        global b_entry_checkbox
        b_entry_checkbox = checkbox.get_active()
        if b_entry_checkbox:
            print "Box checked"
        else:
            print "Not checked"
        return

    def enter_callback_b(self, widget, entry_b):
        global ProdAv
        ProdAv = entry_b.get_text()
        print "Text entry: %s\n" % ProdAv
        return

    def ChCheese(self,entry_b):
        global DbCheese
        DbCheese = entry_b.get_active_text()
        return

    def ChSector(self, entry_b):
        global DbSector
        DbSector = entry_b.get_active_text()
        return
    
    def ChDate1(self, entry_b):
        global DbDate1
        DbDate1 = entry_b.get_active_text()
        return

    def ChDate2(self, entry_b):
        global DbDate2
        DbDate2 = entry_b.get_active_text()
        return

    def DbCalcAv(self,widget,data_a):
        with con:
            Total = 0.
            Count = 0.
            cur = con.cursor(mdb.cursors.DictCursor)
            query = "SELECT * FROM " + DbSector + " ORDER BY " + DbKey
            cur.execute(query)
            rows = cur.fetchall()
            for row in rows:
                if (row[DbCheese] <= 0.):
                    continue
                Count += 1
                #print "%s %s" % (row[DbKey],row[DbCheese])
                Total = Total + row[DbCheese]
            if(Count <= 0):
               Total = 0
               Av = 0
            Av = Total/Count
            cAv = "total: " + "%.1f " % Total + "average: " + "%.1f " % Av + "count: " + "%.0f " % Count 
            self.ProdAv.set_text(cAv)

    def DbCalcEff(self,widget,data_a):
        with con:
            cur = con.cursor(mdb.cursors.DictCursor)
            TotalReception = 0.
            CountReception = 0.
            TotalProduction = 0.
            CountProduction = 0.
            TotalDelivery = 0.
            CountDelivery = 0.
            TotalOrder = 0.
            CountOrder = 0.
            query = "SELECT * FROM reception ORDER BY " + DbKey
            cur.execute(query)
            rows = cur.fetchall()
            DbCol = DbCheese
            if(DbCol == "CaciottaChili"):
               DbCol = "Caciotta"
            if(DbCol == "CaciottaManga"):
               DbCol = "Caciotta"
            if(DbCol == "YogQuarter"):
               DbCol = "Yog"
            if(DbCol == "YogBulk"):
               DbCol = "Yog"
            if(DbCol == "YogLiter"):
               DbCol = "Yog"
            for row in rows:
                if (row[DbCol] <= 0.):
                    continue
                CountReception += 1
                TotalReception += row[DbCol]
            query = "SELECT * FROM production ORDER BY " + DbKey
            cur.execute(query)
            rows = cur.fetchall()
            DbCol = DbCheese
            if(DbCol == "CaciottaChili"):
               DbCol = "Caciotta"
            if(DbCol == "CaciottaManga"):
               DbCol = "Caciotta"
            if(DbCol == "YogQuarter"):
               DbCol = "Yog"
            if(DbCol == "YogBulk"):
               DbCol = "Yog"
            if(DbCol == "YogLiter"):
               DbCol = "Yog"
            for row in rows:
                if (row[DbCol] <= 0.):
                    continue
                CountProduction += 1
                TotalProduction += row[DbCol]
            query = "SELECT * FROM delivery ORDER BY " + DbKey
            cur.execute(query)
            rows = cur.fetchall()
            for row in rows:
                if (row[DbCheese] <= 0.):
                    continue
                CountDelivery += 1
                TotalDelivery += row[DbCheese]
            query = "SELECT * FROM orders ORDER BY " + DbKey
            cur.execute(query)
            rows = cur.fetchall()
            for row in rows:
                if (row[DbCheese] <= 0.):
                    continue
                CountOrder += 1
                TotalOrder += row[DbCheese]
            cAv = "pasteurised: " + "%.0f l " % TotalReception + "produced: " + "%.0f kg " % TotalProduction + "ordered: " + "%.0f kg " % TotalOrder + "delivered: " + "%.0f kg " % TotalDelivery 
            self.ProdSector.set_text(cAv)
            Eff = (TotalReception/TotalProduction)
            Lost = (TotalProduction - TotalDelivery)
            cAv = "efficiency: " + "%.3f l/kg " % Eff + "lost: " + "%s kg " % Lost
            self.ProdEff.set_text(cAv)

    def CalDate1_date_to_string(self):
       year, month, day = self.window1.get_date()
       mytime = time.mktime((year, month+1, day, 0, 0, 0, 0, 0, -1))
        #return time.strftime("%x", time.localtime(mytime))
       DbDate = "%s/%s/13" % (day,month+1)
       return DbDate

    def CalDate2_date_to_string(self):
       year, month, day = self.window2.get_date()
       mytime = time.mktime((year, month+1, day, 0, 0, 0, 0, 0, -1))
        #return time.strftime("%x", time.localtime(mytime))
       DbDate = "%s/%s/13" % (day,month+1)
       return DbDate

    def CalDate1_set_signal_strings(self, sig_str1):
       global DbDate1
       self.Date1.set_text(sig_str1)
       DbDate1 = self.Date1.get()

    def CalDate2_set_signal_strings(self, sig_str2):
       global DbDate2
       self.Date2.set_text(sig_str2)
       DbDate2 = self.Date2.get()

    def CalDate1_set_flags(self):
        options = 0
        for i in range(5):
            if self.settings[i]:
                options = options + (1<<i)
        if self.window1:
            self.window1.display_options(options)

    def CalDate1_day_selected(self, widget):
        buffer = "start: %s" % self.CalDate1_date_to_string()
        self.CalDate1_set_signal_strings(buffer)

    def CalDate2_day_selected(self, widget):
        buffer = "end: %s" % self.CalDate2_date_to_string()
        self.CalDate2_set_signal_strings(buffer)

    def CalDate2_set_flags(self):
        options = 0
        for i in range(5):
            if self.settings[i]:
                options = options + (1<<i)
        if self.window2:
            self.window2.display_options(options)

    def CalDate_toggle_flag(self, toggle):
        j = 0
        for i in range(5):
            if self.flag_checkboxes[i] == toggle:
                j = i

        self.settings[j] = not self.settings[j]
        self.CalDate1_set_flags()
        self.CalDate2_set_flags()


    def __init__(self):
        flags = [
            "1",
            "2",
            "3",
            "4",
            ]
        self.window = None
        self.flag_checkboxes = 5*[None]
        self.settings = 5*[0]
        self.marked_date = 31*[0]

        window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        window.set_title("CaciottaLeaks")
        window.set_border_width(5)
        window.connect("destroy", lambda x: gtk.main_quit())

        window.set_resizable(False)

        vbox = gtk.VBox(False, self.DEF_PAD)
        window.add(vbox)

        # The top part of the window, Calendar, flags and fontsel.
        hbox = gtk.HBox(False, self.DEF_PAD)
        vbox.pack_start(hbox, True, True, self.DEF_PAD)
        hbbox = gtk.HButtonBox()
        hbox.pack_start(hbbox, False, False, self.DEF_PAD)
        hbbox.set_layout(gtk.BUTTONBOX_SPREAD)
        hbbox.set_spacing(5)

        # Calendar widget
        frame = gtk.Frame("Init date")
        hbbox.pack_start(frame, False, True, self.DEF_PAD)
        CalDate1 = gtk.Calendar()
        self.window1 = CalDate1
        self.CalDate1_set_flags()
        CalDate1.mark_day(1)
        self.marked_date[19-1] = 1
        frame.add(CalDate1)
        CalDate1.connect("day_selected", self.CalDate1_day_selected)
        CalDate1.display_options(1)
        CalDate1.select_month(0,2013)
        CalDate1.select_day(1)


        # Calendar widget
        frame = gtk.Frame("End date")
        hbbox.pack_start(frame, False, True, self.DEF_PAD)
        CalDate2 = gtk.Calendar()
        self.window2 = CalDate2
        self.CalDate2_set_flags()
        CalDate2.mark_day(19)
        self.marked_date[19-1] = 1
        frame.add(CalDate2)
        CalDate2.connect("day_selected", self.CalDate2_day_selected)
        CalDate2.display_options(1)
        CalDate2.select_month(3,2013)
        CalDate2.select_day(1)

        separator = gtk.VSeparator()
        hbox.pack_start(separator, False, True, 0)

        vbox2 = gtk.VBox(False, self.DEF_PAD)
        hbox.pack_start(vbox2, False, False, self.DEF_PAD)
  
        bbox = gtk.HButtonBox ()
        vbox.pack_start(bbox, False, False, 0)
        bbox.set_layout(gtk.BUTTONBOX_END)

        #combo box
        ComboCheese = gtk.combo_box_new_text()
        CheeseType = ["Caciotta","CaciottaChili","CaciottaManga","Mozz","MozzPizza","Provolone","Ricotta","Fermenti","Asiago","Feta","Spread","FreshMilk","Yog","YogBulk","YogLiter","YogQuarter"];
        for iCheese in CheeseType:
            ComboCheese.append_text(iCheese)
        ComboCheese.connect('changed', self.ChCheese)
        ComboCheese.set_active(0)  # set the default option to be shown
        ComboCheese.show() 
        LabelCheese = gtk.Label("Cheese:")
        LabelCheese.show()
        bbox.add(LabelCheese)
        bbox.add(ComboCheese)

        #combo box
        ComboSector = gtk.combo_box_new_text()
        SectorType = ["reception","production","orders","delivery"]
        for iSector in SectorType:
            ComboSector.append_text(iSector)
        ComboSector.connect('changed', self.ChSector)
        ComboSector.set_active(0)  # set the default option to be shown
        ComboSector.show()
        LabelSector = gtk.Label("Sector:")
        LabelSector.show()
        bbox.add(LabelSector)
        bbox.add(ComboSector)

        # Build the Right frame with the flags in 
        frame = gtk.Frame("Flags")
        vbox2.pack_start(frame, True, True, self.DEF_PAD)
        vbox3 = gtk.VBox(True, self.DEF_PAD_SMALL)
        frame.add(vbox3)

        for i in range(len(flags)):
            toggle = gtk.CheckButton(flags[i])
            toggle.connect("toggled", self.CalDate_toggle_flag)
            vbox3.pack_start(toggle, True, True, 0)
            self.flag_checkboxes[i] = toggle

        #  Build the Signal-event part.
        frame = gtk.Frame("Milk efficiency")
        vbox.pack_start(frame, True, True, self.DEF_PAD)

        vbox2 = gtk.VBox(True, self.DEF_PAD_SMALL)
        frame.add(vbox2)
  
        hbox = gtk.HBox (False, 3)
        vbox2.pack_start(hbox, False, True, 0)
        label = gtk.Label("data range ")
        hbox.pack_start(label, False, True, 0)
        hbox.pack_start(self.Date1, False, True, 0)
        label = gtk.Label(" ")
        hbox.pack_start(label, False, True, 0)
        hbox.pack_start(self.Date2, False, True, 0)

        hbox = gtk.HBox (False, 3)
        vbox2.pack_start(hbox, False, True, 0)
        label = gtk.Label("Average: ")
        hbox.pack_start(label, False, True, 0)
        self.ProdAv = gtk.Label("")
        hbox.pack_start(self.ProdAv, False, True, 0)

        hbox = gtk.HBox (False, 3)
        vbox2.pack_start(hbox, False, True, 0)
        label = gtk.Label("Sectors: ")
        hbox.pack_start(label, False, True, 0)
        self.ProdSector = gtk.Label("")
        hbox.pack_start(self.ProdSector, False, True, 0)

        hbox = gtk.HBox (False, 3)
        vbox2.pack_start(hbox, False, True, 0)
        label = gtk.Label("Efficiency: ")
        hbox.pack_start(label, False, True, 0)
        self.ProdEff = gtk.Label("")
        hbox.pack_start(self.ProdEff, False, True, 0)

        bbox = gtk.HButtonBox ()
        vbox.pack_start(bbox, False, False, 0)
        bbox.set_layout(gtk.BUTTONBOX_END)

        #button application
        QueryDb = gtk.Button("average")
        QueryDbdata = ("ciccia","ciccio", "cicciuzzo","ciccione")
        QueryDb.connect("clicked", self.DbCalcAv, QueryDbdata)
        QueryDb.set_flags(gtk.CAN_DEFAULT)
        QueryDb.show()
        bbox.add(QueryDb)

        #button application
        QueryDb = gtk.Button("efficiency")
        QueryDbdata = ("ciccia","ciccio", "cicciuzzo","ciccione")
        QueryDb.connect("clicked", self.DbCalcEff, QueryDbdata)
        QueryDb.set_flags(gtk.CAN_DEFAULT)
        QueryDb.show()
        bbox.add(QueryDb)


        button = gtk.Button("Close")
        button.connect("clicked", lambda w: gtk.main_quit())
        bbox.add(button)
        button.set_flags(gtk.CAN_DEFAULT)
        button.grab_default()

        window.show_all()

def main():
    gtk.main()
    return 0

if __name__ == "__main__":
    CaciottaLeaks()
    main()
