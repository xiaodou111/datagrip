--proc_zeys_rt_syb24
--人次在a2,其他都在a1
select * from dm_yb_md_head_sum_qc;
-- 年度 2023||2024	year_yb
-- 会计日-yyyy-mm-dd	receipt_date
-- 普通门店编码	werks_id
-- 门店类型  诊所||药店	md_type
-- 就医地	city_area_name
-- 参保地	insure_region_name
-- 险种类型	insurance_type
-- 医保类型  农保||医保	per_yb_type
-- 人次	yb_per_num
-- 人头	yb_per_headnum
-- 人头基金	head_fund_amount
-- 总费用	total_amount
-- 总额度	total_quota
-- 医疗费用自费总额	personal_pay_amount
-- 医疗费用自理总额	self_charge_amount
-- 国谈额度	gt_quota
-- 基本医疗统筹支付	overall_pay
-- 当年账户支付	current_account_pay
-- 公务员补助统筹支付	public_fund_pay
-- 大病保险支付	illness_subsidy_amount
-- 历年账户支付	history_account_pay
-- 现金支付	personal_cash_amount