import json
import logging
import os
from logging.config import fileConfig
from pathlib import Path
from typing import Tuple

from flask import Flask, Response, jsonify, request
from presidio_analyzer.analyzer_engine import AnalyzerEngine
from presidio_analyzer.analyzer_request import AnalyzerRequest
from presidio_analyzer.nlp_engine import SpacyNlpEngine
from presidio_anonymizer import AnonymizerEngine
from presidio_anonymizer.deanonymize_engine import DeanonymizeEngine
from presidio_anonymizer.entities import InvalidParamException
from presidio_anonymizer.services.app_entities_convertor import \
    AppEntitiesConvertor
from werkzeug.exceptions import HTTPException
from whitenoise import WhiteNoise

logging.basicConfig(level=logging.DEBUG)


class Server:
    def __init__(self):
        self.logger = logging.getLogger("presidio")
        self.logger.setLevel(logging.DEBUG)
        self.app = Flask(__name__)
        self.app.wsgi_app = WhiteNoise(self.app.wsgi_app, root="static/")
        self.engine = AnalyzerEngine(
            supported_languages=["en", "de"],
            nlp_engine=SpacyNlpEngine(
                models={"en": "en_core_web_lg", "de": "de_core_news_md"}
            ),
        )
        self.anonymizer = AnonymizerEngine()
        self.deanonymize = DeanonymizeEngine()
        self.logger.info("presidio starting up")

        @self.app.route("/analyze", methods=["POST"])
        def analyze() -> Tuple[str, int]:
            try:
                req_data = AnalyzerRequest(request.get_json())
                if not req_data.text:
                    raise Exception("No text provided")

                if not req_data.language:
                    raise Exception("No language provided")

                recognizer_result_list = self.engine.analyze(
                    text=req_data.text,
                    language=req_data.language,
                    correlation_id=req_data.correlation_id,
                    score_threshold=req_data.score_threshold,
                    entities=req_data.entities,
                    return_decision_process=req_data.return_decision_process,
                    ad_hoc_recognizers=req_data.ad_hoc_recognizers,
                )

                return Response(
                    json.dumps(
                        recognizer_result_list,
                        default=lambda o: o.to_dict(),
                        sort_keys=True,
                    ),
                    content_type="application/json",
                )
            except TypeError as te:
                error_msg = (
                    f"Failed to parse /analyze request "
                    f"for AnalyzerEngine.analyze(). {te.args[0]}"
                )
                self.logger.error(error_msg)
                return jsonify(error=error_msg), 400

            except Exception as e:
                self.logger.error(
                    f"A fatal error occurred during execution of "
                    f"AnalyzerEngine.analyze(). {e}"
                )
                return jsonify(error=e.args[0]), 500

        @self.app.route("/recognizers", methods=["GET"])
        def recognizers() -> Tuple[str, int]:
            """Return a list of supported recognizers."""
            language = request.args.get("language")
            try:
                recognizers_list = self.engine.get_recognizers(language)
                names = [o.name for o in recognizers_list]
                return jsonify(names), 200
            except Exception as e:
                self.logger.error(
                    f"A fatal error occurred during execution of "
                    f"AnalyzerEngine.get_recognizers(). {e}"
                )
                return jsonify(error=e.args[0]), 500

        @self.app.route("/anonymize", methods=["POST"])
        def anonymize() -> Response:
            content = request.get_json()
            if not content:
                raise BadRequest("Invalid request json")

            anonymizers_config = AppEntitiesConvertor.operators_config_from_json(
                content.get("anonymizers")
            )
            if AppEntitiesConvertor.check_custom_operator(anonymizers_config):
                raise BadRequest("Custom type anonymizer is not supported")

            analyzer_results = AppEntitiesConvertor.analyzer_results_from_json(
                content.get("analyzer_results")
            )
            anoymizer_result = self.anonymizer.anonymize(
                text=content.get("text"),
                analyzer_results=analyzer_results,
                operators=anonymizers_config,
            )
            return Response(anoymizer_result.to_json(), mimetype="application/json")

        @self.app.route("/deanonymize", methods=["POST"])
        def deanonymize() -> Response:
            content = request.get_json()
            if not content:
                raise BadRequest("Invalid request json")
            text = content.get("text")
            deanonymize_entities = AppEntitiesConvertor.deanonymize_entities_from_json(
                content
            )
            deanonymize_config = AppEntitiesConvertor.operators_config_from_json(
                content.get("deanonymizers")
            )
            deanonymized_response = self.deanonymize.deanonymize(
                text=text, entities=deanonymize_entities, operators=deanonymize_config
            )
            return Response(
                deanonymized_response.to_json(), mimetype="application/json"
            )

        @self.app.route("/anonymizers", methods=["GET"])
        def anonymizers():
            """Return a list of supported anonymizers."""
            return jsonify(self.anonymizer.get_anonymizers())

        @self.app.route("/deanonymizers", methods=["GET"])
        def deanonymizers():
            """Return a list of supported deanonymizers."""
            return jsonify(self.deanonymize.get_deanonymizers())

        @self.app.errorhandler(InvalidParamException)
        def invalid_param(err):
            self.logger.warning(
                f"Request failed with parameter validation error: {err.err_msg}"
            )
            return jsonify(error=err.err_msg), 422

        @self.app.route("/supportedentities", methods=["GET"])
        def supported_entities() -> Tuple[str, int]:
            """Return a list of supported entities."""
            language = request.args.get("language")
            try:
                entities_list = self.engine.get_supported_entities(language)
                return jsonify(entities_list), 200
            except Exception as e:
                self.logger.error(
                    f"A fatal error occurred during execution of "
                    f"AnalyzerEngine.supported_entities(). {e}"
                )
                return jsonify(error=e.args[0]), 500

        @self.app.errorhandler(HTTPException)
        def http_exception(e):
            return jsonify(error=e.description), e.code

        @self.app.errorhandler(Exception)
        def server_error(e):
            self.logger.error(f"A fatal error occurred during execution: {e}")
            return jsonify(error="Internal server error"), 500


def main():
    port = int(os.environ.get("PORT", 8000))
    server = Server()
    server.app.run(host="0.0.0.0", port=port)


if __name__ == "__main__":
    main()
