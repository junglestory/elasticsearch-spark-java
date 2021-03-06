<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Search</title>

    <link rel="stylesheet" href="/css/font-awesome.css" />
    <link rel="stylesheet" href="/css/bootstrap.css" />
    <link rel="stylesheet" href="/css/bootstrap-datepicker3.min.css" />
    <link rel="stylesheet" href="/css/awesome-bootstrap-checkbox.css" />
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>

<!-- Main Wrapper -->
<div id="wrapper">
    <div class="content">
        <div class="row">
            <div class="col-md-3">
                <div class="hpanel">
                    <div class="panel-body">
                        <div class="m-b-md">
                            <h4>
                                Filters
                            </h4>
                        </div>

                        <div class="form-group">
                            <label class="control-label">Date:</label>
                            <div class="input-group date">
                                <input type="text" id="filter-start-date" name="filter-start-date" class="form-control" value="${startDate}">
                                <span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
                            </div>
                            <div class="input-group">
                                ~
                            </div>
                            <div class="input-group date">
                                <input type="text" id="filter-end-date" name="filter-end-date" class="form-control" value="${endDate}">
                                <span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label">Fields:</label>
                            <div class="input-group">
                                <#list searchFields as field>
                                    <div class="checkbox checkbox-primary">
                                        <input <#if (fields?index_of(field)>=0)>checked</#if> name="filter-fields" value="${field}" type="checkbox">
                                        <label for="checkbox1">
                                            ${searchFieldsName[field?index]}
                                        </label>
                                    </div>
                                </#list>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="control-label">Sort:</label>
                            <div class="input-group">
                                <select class="form-control m-b" id="filter-sort" name="filter-sort">
                                    <option value="_score" <#if sort == "_score">selected</#if>>Score</option>
                                    <option value="date" <#if sort == "date">selected</#if>>Date</option>
                                </select>
                            </div>
                        </div>

                        <#if buckets??>
                            <div class="form-group">
                                <label class="control-label">Category:</label>
                                <div class="input-group">
                                    <#list buckets as category>
                                        <div class="checkbox checkbox-primary">
                                            <input <#if (categorys?index_of(category.getKeyAsString())>=0)>checked</#if> name="filter-categorys" value="${category.getKeyAsString()}" type="checkbox">
                                            <label for="checkbox1">
                                                ${category.getKeyAsString()} (${category.getDocCount()})
                                            </label>
                                        </div>
                                    </#list>
                                </div>
                            </div>
                        </#if>

                        <button class="btn btn-success btn-block" id="btn-apply">Apply</button>
                    </div>
                </div>
            </div>
            <div class="col-md-9">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="hpanel">
                            <div class="panel-body">
                                <form name="searchForm" id="searchForm" method="get" action="./search">
                                    <div class="input-group">
                                        <input class="form-control" type="text" id="query" name="query" value="${query}" placeholder="Search..">
                                        <div class="input-group-btn">
                                            <button class="btn btn-default" id="search"><i class="fa fa-search"></i></button>
                                        </div>
                                        <input type="hidden" name="pageNum" id="page-num" value="${pageNum}">
                                        <input type="hidden" name="sort" id="sort" value="${sort}">
                                        <input type="hidden" name="fields" id="fields" value="${fields}">
                                        <input type="hidden" name="categorys" id="categorys" value="${categorys}">
                                        <input type="hidden" name="startDate" id="start-date" value="${startDate}">
                                        <input type="hidden" name="endDate" id="end-date" value="${endDate}">
                                    </div>
                                </form>
                                <div style="padding-top: 10px;">
                                    Search Results for <strong>Blogs</strong>  (${totalCount} results)
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">

                    <div class="col-lg-12">
                        <#if results??>
                            <#list results as item>
                                <div class="hpanel filter-item">
                                    <a href="#">
                                    <div class="panel-body">
                                        <div class="pull-right text-right">
                                                <small class="stat-label">${item.sourceAsMap()['date']}</small>

                                        </div>
                                        <h4 class="m-b-xs">
                                            <#if item.highlightFields()["title"]??>
                                                ${item.highlightFields()["title"].fragments()[0]}
                                            <#else>
                                                ${item.sourceAsMap()['title']}
                                            </#if>
                                        </h4>
                                        <p>
                                        ${item.sourceAsMap()['author']} / ${item.sourceAsMap()['category']}
                                        </p>
                                        <p>
                                            <#if item.highlightFields()["desc"]??>
                                                ${item.highlightFields()["desc"].fragments()[0]}
                                            <#else>
                                                ${item.sourceAsMap()['desc']}
                                            </#if>
                                        </p>
                                    </div>
                                    </a>
                                </div>
                            </#list>

                            <div class="text-center">
                                <ul class="pagination">
                                    <li class="paginate_button previous <#if pageNum<=1>disabled</#if>">
                                        <a href="javascript:void(0);" onclick="goPage(${pageNum-1});" aria-controls="example1" data-dt-idx="0" tabindex="0">Previous</a>
                                    </li>
                                    <#list 1..pageCount as i >
                                        <li class="paginate_button <#if pageNum==i>active</#if>">
                                            <a href="javascript:void(0);" onclick="goPage(${i});"  aria-controls="example1" data-dt-idx="1" tabindex="0">${i}</a>
                                        </li>
                                    </#list>

                                    <li class="paginate_button next <#if (pageNum>=pageCount)>disabled</#if>">
                                        <a href="javascript:void(0);" onclick="goPage(${pageNum+1});" aria-controls="example1" data-dt-idx="6" tabindex="0">Next</a>
                                    </li>
                                </ul>
                            </div>
                        </#if>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Vendor scripts -->
<script src="/js/jquery.min.js"></script>
<script src="/js/bootstrap.min.js"></script>
<script src="/js/bootstrap-datepicker.min.js"></script>

<script>

        $(document).ready(function(){
            $("#query").keypress(function( event ) {
                if (event.which == 13) {
                    $("#page-num").val(1);
                    $("#categorys").val("");

                    search();
                }
            });

            $('#search').click(function(){
                $("#page-num").val(1);
                $("#categorys").val("");

                search();
            });

            $('#btn-apply').click(function(){
                var fields = "";
                var categorys = "";

                $("input[name=filter-fields]:checked").each(function() {
                    fields += "," + $(this).val().trim();
                });

                if (fields != "") {
                    fields = fields.substring(1);
                }

                $("input[name=filter-categorys]:checked").each(function() {
                    categorys += "," + $(this).val().trim();
                });

                if (categorys != "") {
                    categorys = categorys.substring(1);
                }

                $("#page-num").val(1);
                $("#sort").val($("select[name=filter-sort]").val());
                $("#fields").val(fields);
                $("#categorys").val(categorys);

                search();
            });
        });

        $('.input-group.date').datepicker();

        var search = function() {
            document.searchForm.submit();
        }

        var goPage = function(pageNum) {
            $("#page-num").val(pageNum);

            search();
        }
</script>


</body>
</html>