
# Create var for which section of the freeway the count station is on
# Group 1 (Ogden -> SLC): Southbound between 307.9 and 343.39 postmiles during morning rush hours and 
    # Northbound between 307.92 and 343.38 postmiles during evening rush hours
grp1_mask = (
    ((tti_df_long['direction'] == 'South') & 
     (tti_df_long['postmile'] >= 307.9) & 
     (tti_df_long['postmile'] <= 343.39)) |
    ((tti_df_long['direction'] == 'North') & 
     (tti_df_long['postmile'] >= 307.92) & 
     (tti_df_long['postmile'] <= 343.38))
)

# Group 2 (Provo -> SLC): Northbound between 265.05 and 307.92 postmiles during morning rush hours and 
    # Southbound between 265.05 and 307.9 postmiles during evening rush hours
grp2_mask = (
    ((tti_df_long['direction'] == 'North') & 
     (tti_df_long['postmile'] >= 265.05) & 
     (tti_df_long['postmile'] <= 307.92)) |
    ((tti_df_long['direction'] == 'South') & 
     (tti_df_long['postmile'] >= 265.05) & 
     (tti_df_long['postmile'] <= 307.9))
)

# Assign groups
tti_n_m_df['group'] = 0  # default
tti_n_m_df.loc[grp1_mask, 'group'] = 1
tti_n_m_df.loc[grp2_mask, 'group'] = 2

