const analysisSchemaVersion = 1;
const analysisPromptVersion = '1.0.0';
const defaultAnalysisModel = 'gpt-5.6-luna';
const analysisConfidenceThreshold = 0.70;
const analysisSensitiveActionThreshold = 0.80;
const analysisMaxAttempts = 3;
const analysisConcurrency = 1;
const analysisRequestTimeout = Duration(seconds: 45);

const analysisEntityKeys = <String>{
  'merchant',
  'productName',
  'priceText',
  'currency',
  'orderNumber',
  'trackingCode',
  'carrier',
  'couponCode',
  'discountText',
  'placeName',
  'address',
  'artist',
  'venue',
  'mediaTitle',
  'creator',
  'recipeName',
  'primaryUrl',
  'phoneNumber',
};

const analysisUncertainFieldNames = <String>{
  'category',
  'subtype',
  'intent',
  'title',
  'summary',
  'sourceApp',
  'requiresAction',
  'suggestedActions',
  'eventAt',
  'expiresAt',
  'location',
  'entities',
  'relevance',
  'searchKeywords',
};
