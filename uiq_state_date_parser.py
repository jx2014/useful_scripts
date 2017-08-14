# UIQ state date parser
# Purpose: sort through mac ID with state and date, calculate state duration. 
# Output: output a csv file with mac ID and each uiq state duration
# 
# date: 3/27/2017

from dateutil.parser import parse
import csv
import os


class UIQ_Duration(object):
    def __init__(self, input_csv):
        #open input csv file
        in_csv = open(input_csv, 'r')
        self.out_csv = self.generate_out_csv_fname(input_csv)
        
        self.header = None
        #read csv file with csv reader
        self.csv_reader = csv.reader(in_csv)
        
#         self.complete_csv_file= []
# 
#         for row in self.csv_reader:
#             self.complete_csv_file.append(row)
#         
#         self.header = self.complete_csv_file[0]
        self.output_fieldnames = ['customer', 'macID', 'days_pre_active', 'days_active', 'rma_received', 'date_installed', 'date_active', 'date_removed']
        
    
    def generate_out_csv_fname(self, in_csv):
        in_fname = os.path.basename(in_csv)
        out_dir = os.path.dirname(in_csv)
        out_fname, out_ext = os.path.splitext(in_fname)
        out_fname = ''.join(['Output_' + out_fname, out_ext])
        out_fpath = os.path.join(out_dir, out_fname)
        
        return out_fpath
    
    def get_delta_date(self, date_str1, date_str2):
        diff = parse(date_str1) - parse(date_str2)
        return abs(diff.days)
    
    def get_uut(self, line):
        # read in each line, starting with customer, mac ID, state, etc
        # output: customer, mac ID, days from New to Active, and from Active to take down
        # days from New to Active include the following states: 5002, 5003, 5004, 5005, 5006
        # days from Active to take down includes the following states: 5008, 5009, 5010, 5011, 5012, 5013, 5014, 5015
        
        customer = line.pop(0)
        macid = line.pop(0)        
        dateRec = line.pop(0)
        
        return customer, macid, dateRec
    
    def get_state_date(self, in_list):
        #remove empty entries
        clean_line = filter(None, in_list) 
                
        customer, macid, dateRec = self.get_uut(clean_line)
        
        uiq_date_pre_active = dateRec #"1/1/1900"
        uiq_date_active = dateRec #"1/1/1900"
        uiq_date_takedown = dateRec #"1/1/1900"
        
        
        while True:
            try:
                uiq_state = clean_line.pop(0)            
                
                if uiq_state in ['5002', '5003', '5004', '5005', '5006']:
                    # if date of uiq_sate is earlier than date of receive, then this is a valid date to use. 
                    if parse(clean_line[0]) < parse(uiq_date_pre_active):
                        uiq_date_pre_active = clean_line.pop(0)
                    else:
                        # date of uiq_state is older than date of receive, invalid and removed.
                        clean_line.pop(0)
                elif uiq_state in ['5007']:
                    # if date of uiq_sate is earlier than date of receive, then this is a valid date to use.
                    if parse(clean_line[0]) < parse(uiq_date_active):
                        uiq_date_active = clean_line.pop(0)
                    else:
                        # date of uiq_state is older than date of receive, invalid and removed.
                        clean_line.pop(0)
                elif uiq_state in ['5008', '5009', '5010', '5011', '5012', '5013', '5014', '5015']:
                    # if date of uiq_sate is earlier than date of receive, then this is a valid date to use.
                    if parse(clean_line[0]) < parse(uiq_date_takedown):
                        uiq_date_takedown = clean_line.pop(0)
                    else:
                        # date of uiq_state is older than date of receive, invalid and removed.
                        clean_line.pop(0)
            except IndexError:
                #print 'get_state_date completed'
                break
            
        # commented out, if uiq_date is not found from csv file, it will be the same date as date of recieve. 
        #uiq_date_pre_active = ( None if parse(uiq_date_pre_active).year == 1900 else uiq_date_pre_active)
        #uiq_date_active = ( None if parse(uiq_date_active).year == 1900 else uiq_date_active)
        #uiq_date_takedown = ( None if parse(uiq_date_takedown).year == 1900 else uiq_date_takedown)

        return  customer, macid, dateRec, uiq_date_pre_active, uiq_date_active, uiq_date_takedown    

    
    def date_to_days(self, receive_date, pre_active_date, active_date, takedown_date):
        '''
            Takes four variables: 
                receive_date, pre_active_date, active_date, takedown_date
                note: Give the same date as receive_date is any date is not available.
                            
            Then Calculate days from install to active and days of active in the field            
            
        '''
        date_receive = parse(receive_date)
        date_pre_active = parse(pre_active_date)
        date_active = parse(active_date)
        date_takedown = parse(takedown_date)
        
        days_pre_act_to_act = (date_active - date_pre_active).days 
        days_pre_act_to_td = (date_takedown - date_pre_active).days
        days_pre_act_to_rec = (date_receive - date_pre_active).days
        
        days_pre_active = self.shorttest_days(days_pre_act_to_act, days_pre_act_to_td, days_pre_act_to_rec)
        
        days_active_to_td = (date_takedown - date_active).days
        days_active_to_rec = (date_receive - date_active).days
        
        days_active = self.shorttest_days(days_active_to_td, days_active_to_rec)
        
        return days_pre_active, days_active
        
    
    def shorttest_days(self, *args):
        actual_days = 99999999
        
        for i in args:
            if i < 0:
                continue # if negative number indicate invalid days, and will be corrected to 0.
            else:
                if i < actual_days:
                    actual_days = i
                else:
                    continue
        
        return actual_days
                
    def process_each_row(self, line):
        customer, macid, dateRec, uiq_date_pre_active, uiq_date_active, uiq_date_takedown = self.get_state_date(line)
        days_pre_active, days_active = self.date_to_days(dateRec, uiq_date_pre_active, uiq_date_active, uiq_date_takedown)
        
        return customer, macid, days_pre_active, days_active, dateRec, uiq_date_pre_active, uiq_date_active, uiq_date_takedown
    
    def init_keys(self, input_list):
        some_dict = {}
        for key in input_list:
            some_dict[key] = None
        return some_dict

    
    def run(self):
        with open(self.out_csv, 'w') as csv_of:
            writer = csv.DictWriter(csv_of, fieldnames = self.output_fieldnames, lineterminator='\n')
            
            writer.writeheader()
            n = 0
            for row in self.csv_reader:
                # initialize row content with empty keys
                write_content = self.init_keys(self.output_fieldnames)
                # ['customer', 'macID', 'days_pre_active', 'days_active', 'rma_received', 'date_installed', 'date_active', 'date_removed']
                write_content['customer'], write_content['macID'], write_content['days_pre_active'], write_content['days_active'], write_content['rma_received'], write_content['date_installed'], write_content['date_active'], write_content['date_removed'] = self.process_each_row(row)                
                writer.writerow(write_content)
                n = n + 1
        
        print "Output file: %s " % os.path.basename(self.out_csv)
        print "Directory: %s" % os.path.dirname(self.out_csv)
        print "# of Mac IDs processed: %s" % n
    
if __name__ == '__main__':
    input_csv = r"C:\Users\jxue\Documents\Projects_LocalDrive\APRelay_RMA_Reduction\Lorenzo\AP_RMA_backbone-device-history.csv"    
    UIQStates = UIQ_Duration(input_csv)
    #UIQStates.get_state_date(UIQStates.complete_csv_file[4])
    UIQStates.run()
    
    


    