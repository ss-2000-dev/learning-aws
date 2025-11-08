### Command
# accountid=$(aws sts get-caller-identity --query "Account" --output text)
# aws s3 cp s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/csv/customers.csv ./customers.csv
# aws s3 cp s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/csv/sales.csv ./sales.csv
# aws s3 cp customers.csv s3://athena-workshop-$accountid/basics/csv/customers/customers.csv
# aws s3 cp sales.csv s3://athena-workshop-$accountid/basics/csv/sales/sales.csv
# rm sales.csv customers.csv
# aws s3 cp s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/parquet/sales.zip ./sales.zip
# unzip -o sales.zip
# rm sales.zip
# aws s3 sync ./sales s3://athena-workshop-$accountid/basics/parquet/sales
# aws s3 cp s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/parquet/customers.zip ./customers.zip
# unzip -o customers.zip
# aws s3 sync ./customers s3://athena-workshop-$accountid/basics/parquet/customers
# echo "----- done -----"
###

### Result
~ $ accountid=$(aws sts get-caller-identity --query "Account" --output text)
~ $ aws s3 cp s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/csv/customers.csv ./customers.csv
download: s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/csv/customers.csv to ./customers.csv
~ $ aws s3 cp s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/csv/sales.csv ./sales.csv
download: s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/csv/sales.csv to ./sales.csv
~ $ aws s3 cp customers.csv s3://athena-workshop-$accountid/basics/csv/customers/customers.csv
upload: ./customers.csv to s3://athena-workshop-618584750402/basics/csv/customers/customers.csv
~ $ aws s3 cp sales.csv s3://athena-workshop-$accountid/basics/csv/sales/sales.csv
upload: ./sales.csv to s3://athena-workshop-618584750402/basics/csv/sales/sales.csv
~ $ rm sales.csv customers.csv
~ $ aws s3 cp s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/parquet/sales.zip ./sales.zip
download: s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/parquet/sales.zip to ./sales.zip
~ $ unzip -o sales.zip
Archive:  sales.zip
 extracting: sales/year=2020/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2020/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2018/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2017/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2019/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2021/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2024/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2023/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet  
 extracting: sales/year=2022/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet  
~ $ rm sales.zip
~ $ aws s3 sync ./sales s3://athena-workshop-$accountid/basics/parquet/sales
upload: sales/year=2017/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2017/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2017/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2018/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2018/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2019/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2019/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2020/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2020/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2021/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2021/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=11/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2022/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2022/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=12/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=4/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=10/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=5/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=2/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=3/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=6/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=8/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=9/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2024/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2024/month=1/ce41065a3d85429f82cb6ebc35231116-0.parquet
upload: sales/year=2023/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet to s3://athena-workshop-618584750402/basics/parquet/sales/year=2023/month=7/ce41065a3d85429f82cb6ebc35231116-0.parquet
~ $ aws s3 cp s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/parquet/customers.zip ./customers.zip
download: s3://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee/9981f1a1-abdc-49b5-8387-cb01d238bb78/v1/parquet/customers.zip to ./customers.zip
~ $ unzip -o customers.zip
Archive:  customers.zip
 extracting: customers/country=United_States/760b6e9743ab4f4593506221223f2252-0.parquet  
 extracting: customers/country=United_Kingdom/760b6e9743ab4f4593506221223f2252-0.parquet  
 extracting: customers/country=Australia/760b6e9743ab4f4593506221223f2252-0.parquet  
~ $ aws s3 sync ./customers s3://athena-workshop-$accountid/basics/parquet/customers
upload: customers/country=Australia/760b6e9743ab4f4593506221223f2252-0.parquet to s3://athena-workshop-618584750402/basics/parquet/customers/country=Australia/760b6e9743ab4f4593506221223f2252-0.parquet
upload: customers/country=United_Kingdom/760b6e9743ab4f4593506221223f2252-0.parquet to s3://athena-workshop-618584750402/basics/parquet/customers/country=United_Kingdom/760b6e9743ab4f4593506221223f2252-0.parquet
upload: customers/country=United_States/760b6e9743ab4f4593506221223f2252-0.parquet to s3://athena-workshop-618584750402/basics/parquet/customers/country=United_States/760b6e9743ab4f4593506221223f2252-0.parquet
~ $ echo "----- done -----"
----- done -----