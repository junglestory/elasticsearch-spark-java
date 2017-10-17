package org.junglestory.search.spark;


import org.elasticsearch.action.search.SearchRequestBuilder;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.transport.InetSocketTransportAddress;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.index.query.RangeQueryBuilder;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightBuilder;
import org.elasticsearch.search.sort.SortOrder;
import org.elasticsearch.transport.client.PreBuiltTransportClient;
import spark.ModelAndView;
import spark.Spark;
import spark.template.freemarker.FreeMarkerEngine;

import java.net.InetAddress;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import static org.elasticsearch.index.query.QueryBuilders.boolQuery;
import static org.elasticsearch.index.query.QueryBuilders.termsQuery;
import static spark.Spark.get;

public class Search {
    private static String index = "blogs";
    private static String type = "blog";
    private static int perPage = 10;
    private static String searchServer = "127.0.0.1";
    private static int searchPort = 9300;
    private static final String SEARCH_FIELDS = "title,desc,author";
    private static final String[] SEARCH_FIELDS_NAME = {"Title", "Desc", "Author"};

    public static void main(String[] args) {

        Spark.staticFileLocation("/public");

        get("/search", (request, response) -> {
            Map<String, Object> attributes = new HashMap<>();

            String query = (request.queryParams("query") == null)?"":request.queryParams("query");
            int pageNum =  (request.queryParams("pageNum") == null)?1:Integer.parseInt(request.queryParams("pageNum"));
            String fields =  (request.queryParams("fields") == null)?"":request.queryParams("fields");
            String categorys =  (request.queryParams("categorys") == null)?"":request.queryParams("categorys");
            String sort = (request.queryParams("sort") == null)?"_score":request.queryParams("sort");
            String startDate = (request.queryParams("startDate") == null)?"":request.queryParams("startDate");
            String endDate = (request.queryParams("endDate") == null)?"":request.queryParams("endDate");
            long totalCount = 0;
            long pageCount = 1;
            SearchHit[] hits = null;

            if (fields.equals("")) {
                fields = SEARCH_FIELDS;
            }

            String[] searchFields = fields.split(",");

            if (endDate.equals("")) {
                endDate = getCurrentDate();
            }

            if (startDate.equals("")) {
                startDate = getStartDate(-30);
            }

            if (query.trim().length() > 0) {
                TransportClient client = new PreBuiltTransportClient(Settings.EMPTY)
                        .addTransportAddress(new InetSocketTransportAddress(InetAddress.getByName(searchServer), searchPort));

                SearchRequestBuilder srb = client.prepareSearch(index).setTypes(type);

                HighlightBuilder highlightBuilder = new HighlightBuilder();

                HighlightBuilder.Field highlightTitle =
                        new HighlightBuilder.Field("title");
                highlightTitle.highlighterType("unified");
                highlightBuilder.field(highlightTitle);

                HighlightBuilder.Field highlightDesc =
                        new HighlightBuilder.Field("desc");
                highlightDesc.preTags("<strong>");
                highlightDesc.postTags("</strong>");
                highlightBuilder.field(highlightDesc);

                BoolQueryBuilder qb = boolQuery();

                // multi match query
                QueryBuilder builder = QueryBuilders.multiMatchQuery(query, searchFields);
                qb.must(builder);

                // range query
                RangeQueryBuilder rangeQuery = QueryBuilders.rangeQuery("date");
                rangeQuery.from(convertDateFormat(startDate));
                rangeQuery.to(convertDateFormat(endDate));
                qb.must(rangeQuery);

                // filter query
                Set<String> filter = new HashSet<String>();
                String[] aryCatetory = categorys.split(",");

                for(String category : aryCatetory) {
                    if (category != null && !category.equals("")) {
                        filter.add(category);
                    }
                }

                if (filter.size() > 0) {
                    QueryBuilder boolBuilder = boolQuery().filter(termsQuery("category", filter));
                    qb.filter(boolBuilder);
                }

                srb.setQuery(qb)
                    .addSort(sort, SortOrder.DESC)
                    .setFrom((pageNum - 1) * perPage)
                    .setSize(perPage)
                    .highlighter(highlightBuilder)
                    .addAggregation(AggregationBuilders.terms("category").field("category"))
                    .setExplain(true)
                ;

                SearchResponse searchResponse = srb.execute().actionGet();

                hits = searchResponse.getHits().getHits();
                totalCount = searchResponse.getHits().getTotalHits();
                pageCount = ((totalCount -1) / perPage) + 1;

                Terms  terms = searchResponse.getAggregations().get("category");
                List<? extends Terms.Bucket> buckets = terms.getBuckets();
                attributes.put("buckets", buckets);

                client.close();
            }

            attributes.put("results", hits);
            attributes.put("totalCount", totalCount);
            attributes.put("pageCount", pageCount);
            attributes.put("pageNum", pageNum);
            attributes.put("query", query);
            attributes.put("sort", sort);
            attributes.put("fields", fields);
            attributes.put("categorys", categorys);
            attributes.put("searchFields", SEARCH_FIELDS.split(","));
            attributes.put("searchFieldsName", SEARCH_FIELDS_NAME);
            attributes.put("startDate", startDate);
            attributes.put("endDate", endDate);

            return new ModelAndView(attributes, "search.ftl");
        }, new FreeMarkerEngine());
    }

    private static String getCurrentDate() {
        SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");
        String date = format.format(new Date());

        return date;
    }

    private static String getStartDate(int day) {
        Calendar cal = Calendar.getInstance();
        SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");
        cal.add(cal.DATE, day);
        String date = format.format(cal.getTime());

        return date;
    }

    private static String convertDateFormat(String strDate) throws ParseException {
        Date date = new SimpleDateFormat("MM/dd/yyyy").parse(strDate);
        return new SimpleDateFormat("yyyy.MM.dd").format(date);
    }

}


