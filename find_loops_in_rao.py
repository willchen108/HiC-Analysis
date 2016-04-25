targetfile = open("/Users/Will/Desktop/gencode.v19_promoter_chr_removed.bed")

promoters={}
total =[]
for line in targetfile:
    ch,st,end = line.split()[0:3]
    st = int(st)
    end = int(end)
    for tar in targets:
    	if tar[0] == ch:
    		if st in range(tar[3],tar[4]) or end in range(tar[3],tar[4]):
    			total.append([tar[0], tar[1], tar[2], tar[3], tar[4], tar[5],st, end])